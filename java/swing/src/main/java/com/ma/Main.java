package com.ma;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

/**
 * Created by mahengyang on 2015-08-12
 */
public class Main extends JFrame {
    private JLabel statusbar;

    public Main() {
        initUI();
    }

    public void initUI() {
        JButton quitButton = new JButton("Quit");
        quitButton.setToolTipText("这里是tips");
        quitButton.setMnemonic(KeyEvent.VK_B);
        quitButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent event) {
                System.exit(0);
            }
        });
        statusbar = new JLabel("Ready");
        statusbar.setBorder(BorderFactory.createEtchedBorder());
        statusbar.setVisible(true);
        add(statusbar, BorderLayout.SOUTH);

//        createLayout(quitButton);
        createMenuBar();

        setTitle("Quit button");
        setSize(360, 250);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
    }
    public void createMenuBar(){
        JMenuBar menuBar = new JMenuBar();
        JMenu file = new JMenu("file");
        file.setMnemonic(KeyEvent.VK_F);
        JMenuItem exitMenuItem = new JMenuItem("Exit");
        exitMenuItem.setMnemonic(KeyEvent.VK_E);
        exitMenuItem.setToolTipText("点击退出");
//        exitMenuItem.setAccelerator();
        exitMenuItem.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                System.exit(0);
            }
        });
        JMenu parentMenu = new JMenu("父菜单");
        JMenuItem subMenuItem1 = new JMenuItem("子菜单1");
        JMenuItem subMenuItem2 = new JMenuItem("子菜单2");
        parentMenu.add(subMenuItem1);
        parentMenu.add(subMenuItem2);
        JCheckBoxMenuItem checkBoxMenuItem = new JCheckBoxMenuItem("显示状态栏");
        checkBoxMenuItem.setSelected(true);
        checkBoxMenuItem.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    statusbar.setVisible(true);
                } else {
                    statusbar.setVisible(false);
                }
            }
        });
        file.add(checkBoxMenuItem);
        file.add(exitMenuItem);
        file.addSeparator();
        file.add(parentMenu);
        menuBar.add(file);
        setJMenuBar(menuBar);
    }

    private void createLayout(JComponent... arg) {
        Container pane = getContentPane();
        GroupLayout gl = new GroupLayout(pane);
        pane.setLayout(gl);
        gl.setAutoCreateContainerGaps(true);

        gl.setHorizontalGroup(gl.createSequentialGroup()
                        .addComponent(arg[0])
                        .addGap(100)
        );

        gl.setVerticalGroup(gl.createSequentialGroup()
                        .addComponent(arg[0])
                        .addGap(20)
        );
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
