import java.awt.Desktop;
import java.awt.EventQueue;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.swing.JOptionPane;

import static java.nio.file.StandardWatchEventKinds.*;

public class AdminTool {
	
	private static final String scriptPath = "CompletedScript\\Main.ps1";
	private static final String reportsPath = "CompletedScript\\Data Sheet\\reports";
	private static final String webPath = new File("CompletedScript\\Data Sheet\\report.html").toURI().toString();

	private static final File userGuide = new File("Guides\\UserGuide.html");
	private static final File developerGuide = new File("Guides\\DevelopersGuide.html");
	private static final Path reportList = Paths.get("CompletedScript\\Data Sheet\\js\\reports.js");
	private static final Path computerList = Paths.get("OtherServers.txt");
	private static final Path appVersions = Paths.get("baseline.txt");
	private static final Path serviceFilter = Paths.get("serviceFilter.txt");
	
	private static final DateTimeFormatter input = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss");
	private static final DateTimeFormatter output = DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm:ss");
	
	private static Thread reportThread;
	
	public static void openUserGuide() {
		try {
			Desktop.getDesktop().open(userGuide);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void openDeveloperGuide() {
		try {
			Desktop.getDesktop().open(developerGuide);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void generateReport(String comment, Runnable onDone) {
		if (reportThread != null)
			throw new IllegalStateException("Only one report can be generated at a time");
		reportThread = new Thread(() -> {
			Process p = null;
			try {
				p = new ProcessBuilder(
						"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", 
						"-ExecutionPolicy", "Bypass",
						"-File", scriptPath,
						"-SkipOpenReports",
						"-Comment", '"' + (comment.isEmpty() ? "None" : comment) + '"'
				).inheritIO().start();
				
				p.waitFor();
			} catch (InterruptedException e) {
				if (p != null)
					p.destroy();
			} catch (IOException e) {
				JOptionPane.showMessageDialog(null, "Failed to run report generator", "Error", JOptionPane.ERROR_MESSAGE);
			}
			EventQueue.invokeLater(onDone);
			reportThread = null;
		});
		reportThread.start();
	}
	
	public static void cancelReport() {
		Thread t = reportThread;
		if (t != null) {
			t.interrupt();
			reportThread = null;
		}
	}
	
	public static void createWatchThread(Runnable onChanged) {
		new Thread(() -> {
			try {
				WatchService watcher = FileSystems.getDefault().newWatchService();
				
				Paths.get(reportsPath).register(watcher, ENTRY_CREATE, ENTRY_DELETE, ENTRY_MODIFY);
				
				while (!Thread.interrupted()) {
					WatchKey key;
					try {
						key = watcher.take();
					} catch (InterruptedException e) {
						break;
					}
					EventQueue.invokeLater(onChanged);
					key.pollEvents();
					key.reset();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}).start();
	}
	
	public static void deleteReports(List<String> reports) {
		for (String r : reports) {
			try {
				Files.delete(Paths.get(reportsPath, r + ".js"));
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		try (Stream<String> stream = Files.lines(reportList)) {
			List<String> lines = stream.filter((s) -> s.startsWith("var") || s.startsWith("];") || !reports.contains(s.substring(1, s.length() - 2)))
			                           .collect(Collectors.toList());
			Files.write(reportList, lines);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void openReport(String id, boolean viewShort) {
		try {
			File temp = File.createTempFile("project6", ".html");
			temp.deleteOnExit();
			try (PrintWriter writer = new PrintWriter(temp, "UTF-8")) {
				String url = webPath + "?short=" + viewShort + "&id=" + id;
				writer.println("<!DOCTYPE html>");
				writer.println("<html>");
				writer.println("<head>");
				writer.println("<meta http-equiv=\"refresh\" content=\"0; url=" + url + "\" />");
				writer.println("</head>");
				writer.println("<body>");
				writer.println("<p><a href=" + url + ">Open Report</p>");
				writer.println("</body>");
				writer.println("</html>");
			}
			Desktop.getDesktop().open(temp);
		} catch (IOException e) {
			System.err.println("Failed to open report: " + id);
			e.printStackTrace();
		}
	}
	
	private static List<String> getReportList() {
		List<String> reports = new ArrayList<>();
		File[] files = new File(reportsPath).listFiles();
		if (files == null) {
			System.err.println("Report path is not a directory");
			System.exit(1);
		}
		for (File r : files) {
			if (r.isFile() && r.canRead() && r.getName().endsWith(".js")) {
				String name = r.getName();
				name = name.substring(0, name.length() - 3);
				try {
					input.parse(name);
				} catch (DateTimeParseException e) {
					continue;
				}
				reports.add(name);
			}
		}
		return reports;
	}
	
	private static String getComment(String id) {
		try (Stream<String> stream = Files.lines(Paths.get(reportsPath, id + ".js"), StandardCharsets.UTF_16)) {
			List<String> lines = stream.filter(s -> s.startsWith("var comment = ")).collect(Collectors.toList());
			
			if (lines.size() != 1)
				return "";
			String commentLine = lines.get(0);
			
			return commentLine.substring(15, commentLine.length() - 2);
		} catch (Exception e) {
			System.err.println("Failed to read comment from report " + id);
			e.printStackTrace();
			return "";
		}
	}
	
	public static String[][] getTableData() {
		List<String> reports = getReportList();
		String[][] data = new String[reports.size()][];
		for (int i = 0; i < reports.size(); i++) {
			String name = reports.get(i);

			data[i] = new String[] { name, output.format(input.parse(name)), getComment(name) }; 
		}
		return data;
	}
	
	public static boolean reportWritable(String id) {
		return Files.isWritable(Paths.get(reportsPath, id + ".js"));
	}
	
	public static boolean reportNotWritable(String id) {
		return !reportWritable(id);
	}
	
	public static void writeComment(String id, String comment) {
		try {
			Path path = Paths.get(reportsPath, id + ".js");
			
			List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_16);
			
			try (PrintWriter writer = new PrintWriter(Files.newBufferedWriter(path, StandardCharsets.UTF_16))) {
				boolean foundComment = false;
				for (String s : lines) {
					if (s.startsWith("var comment = ")) {
						if (foundComment)
							continue;
						foundComment = true;
						writer.println("var comment = \"" + comment + "\";");
					} else {
						writer.println(s);
					}
				}
				if (!foundComment)
					writer.println("var comment = \"" + comment + "\";");
			}
		} catch (Exception e) {
			System.err.println("Failed to write comment to report " + id);
			e.printStackTrace();
		}
	}
	
	public static String[][] getComputerList() {
		try (Stream<String> stream = Files.lines(computerList, StandardCharsets.UTF_16)) {
			return stream.map(s -> new String[] { s })
		                 .toArray(String[][]::new);
		} catch (IOException e) {
			return null;
		}
	}
	
	public static String[][] getAppVersionData() {
		try (Stream<String> stream = Files.lines(appVersions, StandardCharsets.UTF_16)) {
			return stream.map(String::trim)
			             .filter(s -> !s.isEmpty() && !s.equals("Name,Version"))
			             .map(s -> s.split(","))
			             .toArray(String[][]::new);
		} catch (IOException e) {
			return null;
		}
	}
	
	public static String[][] getIgnoredServices() {
		try (Stream<String> stream = Files.lines(serviceFilter, StandardCharsets.UTF_16)) {
			return stream.map(s -> new String[] { s })
			             .toArray(String[][]::new);
		} catch (IOException e) {
			return null;
		}
	}
	
	public static boolean writeComputerList(Vector<Vector<String>> list) {
		try (PrintWriter writer = new PrintWriter(Files.newBufferedWriter(computerList, StandardCharsets.UTF_16))) {
			list.stream().map(s -> s.get(0)).forEach(writer::println);
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public static boolean writeAppVersions(Vector<Vector<String>> list) {
		try (PrintWriter writer = new PrintWriter(Files.newBufferedWriter(appVersions, StandardCharsets.UTF_16))) {
			writer.println("Name,Version");
			list.stream().map(s -> s.get(0) + "," + s.get(1)).forEach(writer::println);
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public static boolean writeServiceFilter(Vector<Vector<String>> list) {
		try (PrintWriter writer = new PrintWriter(Files.newBufferedWriter(serviceFilter, StandardCharsets.UTF_16))) {
			list.stream().map(s -> s.get(0)).forEach(writer::println);
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}
}
