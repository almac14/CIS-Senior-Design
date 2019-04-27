import java.util.function.Consumer;

import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPopupMenu;

@SuppressWarnings("serial")
public class ReportPopupMenu extends JPopupMenu {

	public ReportPopupMenu(boolean blockEdit, String comment, Consumer<Boolean> onClick, Consumer<String> onEditComment) {
		JMenuItem openShortView = new JMenuItem("Open Short View");
		add(openShortView);
		openShortView.addActionListener(e -> onClick.accept(true));
		
		JMenuItem openFullView = new JMenuItem("Open Full View");
		add(openFullView);
		openFullView.addActionListener(e -> onClick.accept(false));
		
		JMenuItem editComment = new JMenuItem("Edit Comment");
		add(editComment);
		if (blockEdit) {
			editComment.setEnabled(false);
			editComment.setToolTipText("Cannot write to report file");
		}
		editComment.addActionListener(e -> {
			String newComment = JOptionPane.showInputDialog("Enter Comment:", comment);
			if (newComment != null)
				onEditComment.accept(newComment);
		});
	}
}
