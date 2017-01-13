package de.tuebingen.uni.sfs.cmdi2marc;

import java.io.File;
import java.io.IOException;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

public class SessionTmpDir implements HttpSessionListener {

	@Override
	public void sessionCreated(HttpSessionEvent arg0) {
	}

	@Override
	public void sessionDestroyed(HttpSessionEvent event) {
		File tmpDir = getSessionDir(event.getSession());
		if (!tmpDir.exists()) {
			return;
		}
		for (File f : tmpDir.listFiles()) {
			f.delete();
		}
		tmpDir.delete();
	}

	public static File getSessionDir(HttpSession session) {
		File tmpRoot = (File) session.getServletContext().getAttribute(
				"javax.servlet.context.tempdir");
		if (tmpRoot == null)
			throw new NullPointerException();
		File tmpDir = new File(tmpRoot.getPath() + File.separator + session.getId());
		return tmpDir;
	}

	public static File newFile(HttpSession session, String suffix) throws IOException {
		File tmpDir = getSessionDir(session);
		if (!tmpDir.exists()) {
			tmpDir.mkdir();
		}
		File file = File.createTempFile("tmp", suffix, tmpDir);
		file.deleteOnExit();
		return file;
	}

	public static File newNamedFile(HttpSession session, String name) throws IOException {
		File tmpDir = getSessionDir(session);
		if (!tmpDir.exists()) {
			tmpDir.mkdir();
		}
		File file = new File(tmpDir.getPath() + File.separator + name);
		file.deleteOnExit();
		return file;
	}
}
