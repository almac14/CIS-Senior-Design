import java.awt.BorderLayout;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.table.DefaultTableModel;
import javax.swing.JTabbedPane;
import javax.swing.JScrollPane;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.JButton;
import javax.swing.BoxLayout;

import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

@SuppressWarnings("serial")
public class BaselineEditor extends JFrame {
	
	private JPanel contentPane;
	private JButton btnSave;
	private DefaultTableModel computerListModel = new DefaultTableModel();
	private DefaultTableModel appVersionsModel = new DefaultTableModel();
	private DefaultTableModel serviceFilterModel = new DefaultTableModel();
	
	private boolean needToSave = false;
	
	public BaselineEditor() {
		super("Baseline Editor");
		setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
		setBounds(100, 100, 600, 450);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		contentPane.setLayout(new BorderLayout(0, 0));
		setContentPane(contentPane);
		
		JTabbedPane tabbedPane = new JTabbedPane(JTabbedPane.TOP);
		contentPane.add(tabbedPane, BorderLayout.CENTER);
		
		JPanel computerListPanel = new JPanel();
		tabbedPane.addTab("Computer List", null, computerListPanel, null);
		computerListPanel.setLayout(new BorderLayout(0, 0));
		
		JPanel buttonPanel = new JPanel();
		computerListPanel.add(buttonPanel, BorderLayout.WEST);
		buttonPanel.setLayout(new BoxLayout(buttonPanel, BoxLayout.Y_AXIS));
		
		JButton btnAdd = new JButton("Add");
		btnAdd.setAlignmentX(Component.CENTER_ALIGNMENT);
		buttonPanel.add(btnAdd);
		
		JButton btnEdit = new JButton("Edit");
		btnEdit.setEnabled(false);
		btnEdit.setAlignmentX(Component.CENTER_ALIGNMENT);
		buttonPanel.add(btnEdit);
		
		JButton btnRemove = new JButton("Remove");
		btnRemove.setEnabled(false);
		btnRemove.setAlignmentX(Component.CENTER_ALIGNMENT);
		buttonPanel.add(btnRemove);
		
		JScrollPane scrollPane = new JScrollPane();
		computerListPanel.add(scrollPane, BorderLayout.CENTER);
		
		JTable computerList = new JTable(computerListModel) {
			@Override
			public boolean isCellEditable(int row, int col) {
				return false;
			}
		};
		computerList.setRowHeight(MainWindow.primaryFont.getSize() + 5);
		computerList.setTableHeader(null);
		scrollPane.setViewportView(computerList);
		
		JPanel appVersionsPanel = new JPanel();
		tabbedPane.addTab("App Versions", null, appVersionsPanel, null);
		appVersionsPanel.setLayout(new BorderLayout(0, 0));
		
		JPanel buttonPanel2 = new JPanel();
		appVersionsPanel.add(buttonPanel2, BorderLayout.WEST);
		buttonPanel2.setLayout(new BoxLayout(buttonPanel2, BoxLayout.Y_AXIS));
		
		JButton btnAdd2 = new JButton("Add");
		btnAdd2.setAlignmentX(0.5f);
		buttonPanel2.add(btnAdd2);
		
		JButton btnEdit2 = new JButton("Edit");
		btnEdit2.setEnabled(false);
		btnEdit2.setAlignmentX(0.5f);
		buttonPanel2.add(btnEdit2);
		
		JButton btnRemove2 = new JButton("Remove");
		btnRemove2.setEnabled(false);
		btnRemove2.setAlignmentX(0.5f);
		buttonPanel2.add(btnRemove2);
		
		JScrollPane scrollPane2 = new JScrollPane();
		appVersionsPanel.add(scrollPane2, BorderLayout.CENTER);
		
		JTable appVersionsTable = new JTable(appVersionsModel) {
			@Override
			public boolean isCellEditable(int row, int col) {
				return false;
			}
		};
		appVersionsTable.setRowHeight(MainWindow.primaryFont.getSize() + 5);
		appVersionsTable.getTableHeader().setReorderingAllowed(false);
		scrollPane2.setViewportView(appVersionsTable);
		
		JPanel serviceFilterPanel = new JPanel();
		tabbedPane.addTab("Ignored Services", null, serviceFilterPanel, null);
		serviceFilterPanel.setLayout(new BorderLayout(0, 0));
		
		JPanel buttonPanel3 = new JPanel();
		serviceFilterPanel.add(buttonPanel3, BorderLayout.WEST);
		buttonPanel3.setLayout(new BoxLayout(buttonPanel3, BoxLayout.Y_AXIS));
		
		JButton btnAdd3 = new JButton("Add");
		btnAdd3.setAlignmentX(0.5f);
		buttonPanel3.add(btnAdd3);
		
		JButton btnEdit3 = new JButton("Edit");
		btnEdit3.setEnabled(false);
		btnEdit3.setAlignmentX(0.5f);
		buttonPanel3.add(btnEdit3);
		
		JButton btnRemove3 = new JButton("Remove");
		btnRemove3.setEnabled(false);
		btnRemove3.setAlignmentX(0.5f);
		buttonPanel3.add(btnRemove3);
		
		JScrollPane scrollPane3 = new JScrollPane();
		serviceFilterPanel.add(scrollPane3, BorderLayout.CENTER);
		
		JTable serviceFilterList = new JTable(serviceFilterModel) {
			@Override
			public boolean isCellEditable(int row, int col) {
				return false;
			}
		};
		serviceFilterList.setRowHeight(MainWindow.primaryFont.getSize() + 5);
		serviceFilterList.setTableHeader(null);
		scrollPane3.setViewportView(serviceFilterList);
		
		JPanel panel = new JPanel();
		contentPane.add(panel, BorderLayout.SOUTH);
		panel.setLayout(new FlowLayout(FlowLayout.RIGHT, 5, 2));
		
		JButton btnSaveAndClose = new JButton("Save and Close");
		panel.add(btnSaveAndClose);
		
		btnSave = new JButton("Save");
		btnSave.setEnabled(false);
		panel.add(btnSave);
		
		JButton btnClose = new JButton("Close");
		panel.add(btnClose);
		
		computerList.getSelectionModel().addListSelectionListener(e -> {
			int num = computerList.getSelectedRows().length;
			btnEdit.setEnabled(num == 1);
			btnRemove.setEnabled(num > 0);
		});
		
		appVersionsTable.getSelectionModel().addListSelectionListener(e -> {
			int num = appVersionsTable.getSelectedRows().length;
			btnEdit2.setEnabled(num == 1);
			btnRemove2.setEnabled(num > 0);
		});
		
		serviceFilterList.getSelectionModel().addListSelectionListener(e -> {
			int num = serviceFilterList.getSelectedRows().length;
			btnEdit3.setEnabled(num == 1);
			btnRemove3.setEnabled(num > 0);
		});
		
		addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				if (!cancelClose())
					BaselineEditor.this.dispose();
			}
		});
		
		btnAdd.addActionListener(e -> addRow1(computerList, "Computer Name"));
		btnEdit.addActionListener(e -> editSelectedRow1(computerList, "Computer Name"));
		btnRemove.addActionListener(e -> removeSelectedRows(computerList));
		
		computerList.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {
				if (e.getKeyCode() == KeyEvent.VK_DELETE)
					removeSelectedRows(computerList);
			}
		});
		
		
		btnAdd2.addActionListener(e -> addRow2(appVersionsTable, "Application Name", "Application Version"));
		btnEdit2.addActionListener(e -> editSelectedRow2(appVersionsTable, "Application Name", "Application Version"));
		btnRemove2.addActionListener(e -> removeSelectedRows(appVersionsTable));
		
		appVersionsTable.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {
				if (e.getKeyCode() == KeyEvent.VK_DELETE)
					removeSelectedRows(appVersionsTable);
			}
		});

		
		btnAdd3.addActionListener(e -> addRow1(serviceFilterList, "Service Name"));
		btnEdit3.addActionListener(e -> editSelectedRow1(serviceFilterList, "Service Name"));
		btnRemove3.addActionListener(e -> removeSelectedRows(serviceFilterList));
		
		serviceFilterList.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {
				if (e.getKeyCode() == KeyEvent.VK_DELETE)
					removeSelectedRows(serviceFilterList);
			}
		});
		
		
		btnSave.addActionListener(e -> saveData());
		
		btnSaveAndClose.addActionListener(e -> {
			saveData();
			dispose();
		});
		
		btnClose.addActionListener(e -> {
			if (!cancelClose())
				dispose();
		});
		
		initData();
	}
	
	private void initData() {
		String[][] computerList = AdminTool.getComputerList();
		if (computerList == null) {
			JOptionPane.showMessageDialog(null, "Failed to load computer list file", "Error", JOptionPane.ERROR_MESSAGE);
			dispose();
		}
		computerListModel.setDataVector(computerList, new Object[]{""});
		
		String[][] appVersions = AdminTool.getAppVersionData();
		if (appVersions == null) {
			JOptionPane.showMessageDialog(null, "Failed to load computer list file", "Error", JOptionPane.ERROR_MESSAGE);
			dispose();
		}
		appVersionsModel.setDataVector(appVersions, new String[] { "Name", "Version" });
		
		String[][] ignoredServices = AdminTool.getIgnoredServices();
		if (ignoredServices == null) {
			JOptionPane.showMessageDialog(null, "Failed to load computer list file", "Error", JOptionPane.ERROR_MESSAGE);
			dispose();
		}
		serviceFilterModel.setDataVector(ignoredServices, new Object[]{""});
	}
	
	private void addRow1(JTable table, String inputName) {
		DefaultTableModel model = (DefaultTableModel)table.getModel();
		String value = JOptionPane.showInputDialog("Enter " + inputName + ":");
		if (value == null)
			return;
		
		value = value.trim();
		if (value.isEmpty())
			return;
		
		model.addRow(new String[] { value });
		editData();
	}
	
	private void editSelectedRow1(JTable table, String inputName) {
		DefaultTableModel model = (DefaultTableModel)table.getModel();
		int row = table.getSelectedRow();
		Object oldValue = model.getValueAt(row, 0);
		
		String value = JOptionPane.showInputDialog("Enter " + inputName + ":", oldValue);
		if (value == null)
			return;
		
		value = value.trim();
		if (value.isEmpty())
			return;
		
		model.setValueAt(value, row, 0);
		editData();
	}
	
	private void removeSelectedRows(JTable table) {
		DefaultTableModel model = (DefaultTableModel)table.getModel();
		int[] rows = table.getSelectedRows();
		for (int i = rows.length - 1; i >= 0; i--)
			model.removeRow(rows[i]);
		editData();
	}
	
	private void addRow2(JTable table, String inputName1, String inputName2) {
		DefaultTableModel model = (DefaultTableModel)table.getModel();
		String value1 = JOptionPane.showInputDialog("Enter " + inputName1 + ":");
		if (value1 == null)
			return;
		
		value1 = value1.trim();
		if (value1.isEmpty())
			return;
		
		String value2 = JOptionPane.showInputDialog("Enter " + inputName2 + ":");
		if (value2 == null)
			return;
		
		value2 = value2.trim();
		if (value2.isEmpty())
			return;
		
		model.addRow(new String[] { value1, value2 });
		editData();
	}
	
	private void editSelectedRow2(JTable table, String inputName1, String inputName2) {
		DefaultTableModel model = (DefaultTableModel)table.getModel();
		int row = table.getSelectedRow();
		Object oldValue1 = model.getValueAt(row, 0);
		Object oldValue2 = model.getValueAt(row, 1);
		
		String value1 = JOptionPane.showInputDialog("Enter " + inputName1 + ":", oldValue1);
		if (value1 == null)
			return;
		
		value1 = value1.trim();
		if (value1.isEmpty())
			return;
		
		String value2 = JOptionPane.showInputDialog("Enter " + inputName2 + ":", oldValue2);
		if (value2 == null)
			return;
		
		value2 = value2.trim();
		if (value2.isEmpty())
			return;
		
		model.setValueAt(value1, row, 0);
		model.setValueAt(value2, row, 1);
		editData();
	}
	
	private void editData() {
		if (needToSave)
			return;
		
		needToSave = true;
		btnSave.setEnabled(true);
		setTitle("Baseline Editor *");
	}
	
	@SuppressWarnings("unchecked")
	private void saveData() {
		if (!needToSave)
			return;
		
		if (!AdminTool.writeComputerList(computerListModel.getDataVector())) {
			JOptionPane.showMessageDialog(null, "Failed to save to computer list", "Error", JOptionPane.ERROR_MESSAGE);
			return;
		}
		if (!AdminTool.writeAppVersions(appVersionsModel.getDataVector())) {
			JOptionPane.showMessageDialog(null, "Failed to save to app versions", "Error", JOptionPane.ERROR_MESSAGE);
			return;
		}
		if (!AdminTool.writeServiceFilter(serviceFilterModel.getDataVector())) {
			JOptionPane.showMessageDialog(null, "Failed to save to service filter", "Error", JOptionPane.ERROR_MESSAGE);
			return;
		}
		
		needToSave = false;
		btnSave.setEnabled(false);
		setTitle("Baseline Editor");
	}
	
	private boolean cancelClose() {
		return needToSave && JOptionPane.showConfirmDialog(null, "There are unsaved changes. Are you sure you want to close the editor?\n(Unsaved changes will be lost)") != 0;
	}
}
