package com.ma;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

/**
 * Created by mahengyang on 2015-08-12
 */
public class Main extends JFrame {
    JProgressBar bar = new JProgressBar();
    JLabel label = new JLabel();
    Timer timer;
    JButton b1;

    public Main() {
        setFont();
        initUI();
    }

    public void setFont(){
        Font vFont = new Font("Dialog", Font.PLAIN, 13);

        UIManager.put("ToolTip.font", vFont);

        UIManager.put("Table.font", vFont);

        UIManager.put("TableHeader.font", vFont);

        UIManager.put("TextField.font", vFont);

        UIManager.put("ComboBox.font", vFont);

        UIManager.put("TextField.font", vFont);

        UIManager.put("PasswordField.font", vFont);

        UIManager.put("TextArea.font", vFont);

        UIManager.put("TextPane.font", vFont);

        UIManager.put("EditorPane.font", vFont);

        UIManager.put("FormattedTextField.font", vFont);

        UIManager.put("Button.font", vFont);

        UIManager.put("CheckBox.font", vFont);

        UIManager.put("RadioButton.font", vFont);

        UIManager.put("ToggleButton.font", vFont);

        UIManager.put("ProgressBar.font", vFont);

        UIManager.put("DesktopIcon.font", vFont);

        UIManager.put("TitledBorder.font", vFont);

        UIManager.put("Label.font", vFont);

        UIManager.put("List.font", vFont);

        UIManager.put("TabbedPane.font", vFont);

        UIManager.put("MenuBar.font", vFont);

        UIManager.put("Menu.font", vFont);

        UIManager.put("MenuItem.font", vFont);

        UIManager.put("PopupMenu.font", vFont);

        UIManager.put("CheckBoxMenuItem.font", vFont);

        UIManager.put("RadioButtonMenuItem.font", vFont);

        UIManager.put("Spinner.font", vFont);

        UIManager.put("Tree.font", vFont);

        UIManager.put("ToolBar.font", vFont);

        UIManager.put("OptionPane.messageFont", vFont);

        UIManager.put("OptionPane.buttonFont", vFont);
    }

    public void initUI() {
        bar.setOrientation(JProgressBar.HORIZONTAL);
        bar.setMinimum(0);
        bar.setMaximum(100);
        bar.setValue(0);
        bar.setStringPainted(true);
        bar.addChangeListener(new ChangeListener() {
            @Override
            public void stateChanged(ChangeEvent e) {
                int value  = bar.getValue();
                if (e.getSource() == bar) {
                    label.setText("已经处理了："+value + "%");
                }
            }
        });
        timer = new Timer(50, new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                int value = bar.getValue();
                if (value < 100) {
                    bar.setValue(++value);
                } else {
                    timer.stop();
                    bar.setValue(0);
                }
            }
        });
        JButton quitButton = new JButton("Quit");
        quitButton.setToolTipText("这里是tips");
        quitButton.setMnemonic(KeyEvent.VK_B);
        quitButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent event) {
                System.exit(0);
            }
        });
        createLayout();
        createMenuBar();

        setTitle("自动货架操作");
        setSize(800, 600);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
    }
    public void createMenuBar(){
        JMenuBar menuBar = new JMenuBar();
        JMenu file = new JMenu("菜单");
        file.setMnemonic(KeyEvent.VK_F);
        JMenuItem exitMenuItem = new JMenuItem("Exit");
        exitMenuItem.setMnemonic(KeyEvent.VK_E);
        exitMenuItem.setToolTipText("点击退出");
        exitMenuItem.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                System.exit(0);
            }
        });
        JMenu parentMenu = new JMenu("父菜单");
        JMenuItem subMenuItem1 = new JMenuItem("子菜单1");
        JMenuItem subMenuItem2 = new JMenuItem("子菜单2");
        subMenuItem1.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                int result = JOptionPane.showConfirmDialog(null,"你确认？","确定？",JOptionPane.YES_NO_CANCEL_OPTION);
                JOptionPane.showMessageDialog(null,"你选择了："+result);
            }
        });

        parentMenu.add(subMenuItem1);
        parentMenu.add(subMenuItem2);

        file.add(exitMenuItem);
        file.addSeparator();
        file.add(parentMenu);
        menuBar.add(file);
        setJMenuBar(menuBar);
    }

    private void createLayout() {
        Container pane = getContentPane();
        pane.setLayout(new FlowLayout());
        JTextField aText = new JTextField();
        aText.setColumns(5);
        JTextField bText = new JTextField();
        bText.setColumns(5);
        JTextField cText = new JTextField();
        cText.setColumns(10);
        pane.add(aText);
        pane.add(bText);
        b1 = new JButton("相加");
        pane.add(b1);
        pane.add(cText);
        b1.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                timer.start();
            }
        });
        pane.add(bar);
        pane.add(label);
        pack();
    }

    public static void main(String[] args) {
        EventQueue.invokeLater(new Runnable() {

            @Override
            public void run() {
                Main ex = new Main();
                ex.setVisible(true);
            }
        });
    }
}
