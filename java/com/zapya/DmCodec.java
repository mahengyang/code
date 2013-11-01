package com.zapya;

import java.io.ByteArrayOutputStream;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.List;
// import com.dewmobile.library.common.logging.DmLog;

public class DmCodec {
    
    public static void main(String[] args) {
//         String str1 = "eyJuIjoia6bG85YyF5pyo5YWsIiawiadGV4dCI6IntcIm90XCI6MSxcImNhdFwiaOjQsXCJybVwiaOmZhbHNlLFwiab3BcIjpcIlxcXC9kYXRhXFxcL2FwcFxcXC9jb20udGVuY2VudC5tb2JpbGVxcS0xLmFwa1wiaLFwiaY1wiaOlwiaXCIsXCJwa2dcIjpcImNvbS50ZW5jZW50Lm1vYmlsZXFxXCIsXCJvXCI6XCI1MTA1MFwiaLFwiab3pcIjpcIjEwMDAwODAxXCIsXCJ0aFwiaOltcIjQ2XCJdLFwiadFwiaOlwia5omL5py6UVEyMDEyXCIsXCJfaWRcIjpcIjUyNzU4M1wiaLFwiacHpcIjpcIjEwMDAwODAxXCIsXCJwXCI6XCI1MTA1MFwiaLFwiacHRcIjoxLFwiac3RcIjowfSIsImZyb20iaOiaJQdXJwbGUiaLCJzIjoxLCJ6IjoiaOTg2MTk3ODYiafQ";
// //        String str2 = "体坛二哥";
// //        String encStr = DmCodec.encodeB62(str2.getBytes());
//         byte[] decStr = DmCodec.decodeB62(str1.toCharArray());
// //        System.out.println(str2 + " -> " + encStr);
//         System.out.println(str1 + " -> " + new String(decStr));
//     }
}
	private static final String tag = DmCodec.class.getName();

	private  char[] encodes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
			.toCharArray();
	private  byte[] decodes = new byte[256];
	// static {
	// 	for (int i = 0; i < encodes.length; i++) {
	// 		decodes[encodes[i]] = (byte) i;
	// 	}
	// }

	/**
	 * Build an hexadecimal MD5 hash for a String
	 * 
	 * @param value
	 *            The String to hash
	 * @return An hexadecimal Hash
	 */
	public String hexMD5Str(String value) {
		return byte2Hex(hexMD5(value));
	}

	public byte[] hexMD5(String value) {
		try {
			MessageDigest messageDigest = MessageDigest.getInstance("MD5");
			messageDigest.reset();
			messageDigest.update(value.getBytes());
			byte[] digest = messageDigest.digest();
			return digest;
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return null;
	}

	public String byte2Hex(byte[] b) {
		String stmp = "";
		StringBuilder sb = new StringBuilder("");
		for (int n = 0; n < b.length; n++) {
			stmp = Integer.toHexString(b[n] & 0xFF);
			sb.append((stmp.length() == 1) ? "0" + stmp : stmp);
		}
		return sb.toString();
	}

	public byte[] hex2byte(String str) {
		byte[] b = null;
		if (str != null && str.length() % 2 == 0
				&& str.toLowerCase().matches("[0-9a-z]+")) {
			b = new byte[str.length() / 2];
			for (int i = 0; i < str.length(); i += 2) {
				b[i / 2] = Integer.valueOf(str.substring(i, i + 2), 16)
						.byteValue();
			}
		}
		return b;
	}

	public String encodeB62(byte[] data) {
		StringBuffer sb = new StringBuffer(data.length * 2);
		try {
			int pos = 0, val = 0;
			for (int i = 0; i < data.length; i++) {
//			    System.out.println("data[" + i + "] = " + data[i]);
				val = (val << 8) | (data[i] & 0xFF);
//				System.out.println("val = " + val);
				pos += 8;
				while (pos > 5) {
					char c = encodes[val >> (pos -= 6)];
//					System.out.println("1. c = " + c);
//					System.out.println("1. " + sb.toString());
					sb.append(
					/**/c == 'i' ? "ia" :
					/**/c == '+' ? "ib" :
					/**/c == '/' ? "ic" : c);
//					System.out.println("2. " + sb.toString());
					val &= ((1 << pos) - 1);
//					System.out.println("val = " + val);
				}
			}
			if (pos > 0) {
				char c = encodes[val << (6 - pos)];
//				System.out.println("2. c = " + c);
				sb.append(
				/**/c == 'i' ? "ia" :
				/**/c == '+' ? "ib" :
				/**/c == '/' ? "ic" : c);
			}
		} catch (Exception e) {
			// DmLog.w(tag, e.getMessage());
		}
		return sb.toString();
	}

	public byte[] decodeB62(char[] data) {
		ByteArrayOutputStream baos = new ByteArrayOutputStream(data.length);
		try {
			int pos = 0, val = 0;
			for (int i = 0; i < data.length; i++) {
				char c = data[i];
				if (c == 'i') {
					c = data[++i];
					c =
					/**/c == 'a' ? 'i' :
					/**/c == 'b' ? '+' :
					/**/c == 'c' ? '/' : data[--i];
				}
				val = (val << 6) | decodes[c];
				pos += 6;
				while (pos > 7) {
					baos.write(val >> (pos -= 8));
					val &= ((1 << pos) - 1);
				}
			}
		} catch (Exception e) {
			// DmLog.w(tag, e.getMessage());
		}
		return baos.toByteArray();
	}
	
	/**
	 * Return true if every char in the given char array is in Base62 acceptable.  But, it is no guarantee that
	 * the given char array is Base62 encoded.
	 * @param data
	 * @return
	 */
	public boolean isB62Acceptable(char[] data) {
		if (data == null || data.length == 0) return false;
		boolean isValid = false;
		
		for (int i = 0; i < data.length; i++) {
			char c = data[i];
			isValid = false;
			for (int j = 0; j < encodes.length; j++) {
				if (encodes[j] == c) {
					isValid = true;
				}
			}
			if (isValid == false) {
				// one mismatch char
				return false;
			}
		}
		
		return true;
	}


}
