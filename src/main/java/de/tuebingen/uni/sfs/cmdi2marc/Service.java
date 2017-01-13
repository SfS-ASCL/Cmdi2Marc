package de.tuebingen.uni.sfs.cmdi2marc;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.StreamingOutput;
import javax.xml.xquery.XQException;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 *
 * @author edima
 */
@Produces(MediaType.APPLICATION_JSON)
@Path("/")
public class Service {

	@Context
	HttpServletRequest request;
	@Context
	HttpServletResponse response;

	@GET
	@Path("multi/{sessiondir}/{id}")
	@Consumes(MediaType.MULTIPART_FORM_DATA)
	public Response getFile(@PathParam("sessiondir") String sessiondir, @PathParam("id") String id) throws IOException {
		final File dir = SessionTmpDir.getSessionDir(request.getSession()).getParentFile();
		final File f = new File(dir, sessiondir + File.separator + id);
		if (!f.exists()) {
//			System.out.println("file not found: " + f.getAbsolutePath());
			return Response.status(404).entity("File not found: " + id).build();
		}
		StreamingOutput stream = new StreamingOutput() {
			@Override
			public void write(OutputStream output) throws IOException, WebApplicationException {
				Files.copy(f.toPath(), output);
			}
		};
		return Response.ok(stream, "text/xml")
				.header("content-disposition", "attachment; filename=" + f.getName())
				.build();
	}

	public static class FileEntry {

		public final String name;
		public final File file;

		public FileEntry(String name, File file) {
			this.name = name;
			this.file = file;
		}
	}

	public static List<FileEntry> extractFiles(HttpServletRequest request) throws Exception {
		List<FileEntry> files = new ArrayList<>();
		if (ServletFileUpload.isMultipartContent(request)) {
			FileItemFactory factory = new DiskFileItemFactory();
			ServletFileUpload upload = new ServletFileUpload(factory);
			for (Object item : upload.parseRequest(request)) {
				if (item instanceof FileItem) {
					FileItem fi = (FileItem) item;
					if (!fi.isFormField()) { // it's a file
						File f = SessionTmpDir.newNamedFile(request.getSession(), fi.getName());
						fi.write(f);
						files.add(new FileEntry(fi.getName(), f));
					}
				}
			}
		}
		return files;
	}

	@POST
	@Path("multi")
	@Consumes(MediaType.MULTIPART_FORM_DATA)
	@Produces(MediaType.APPLICATION_JSON)
	public Response postMulti() throws IOException {
		try {
			if (!ServletFileUpload.isMultipartContent(request)) {
				return Response.status(400).entity("Multipart content expected, and this is not").build();
			}

			List<FileEntry> files = extractFiles(request);
			Map<String, String> results = new HashMap<>();
			if (files.isEmpty()) {
				return Response.status(400).entity("No file!").build();
			}
			String sessiondir = SessionTmpDir.getSessionDir(request.getSession()).getName();
			for (FileEntry fileEntry : files) {
//				File result = fileEntry.file;
				File result = CMDICast.castFile(fileEntry.file);
				results.put(result.getName(), "rest/multi/" + sessiondir + "/" + result.getName());
			}
			return Response.ok().entity(results).build();
		} catch (FileNotFoundException xc) {
			return Response.status(404).entity(xc.toString()).build();
		} catch (XQException xc) {
			return Response.status(400).entity(xc.toString()).build();
		} catch (Exception xc) {
			return Response.status(500).entity(xc.toString()).build();
		}
	}

	@POST
	@Path("/")
	public Response postDirect(InputStream is) throws IOException, Exception {
		File fcmdi = File.createTempFile("cmdi2marc-", ".xml");
		fcmdi.delete(); // needed by Files.copy
		Files.copy(is, fcmdi.toPath());
		final File fmarc = CMDICast.castFile(fcmdi);
		StreamingOutput stream = new StreamingOutput() {
			@Override
			public void write(OutputStream output) throws IOException, WebApplicationException {
				Files.copy(fmarc.toPath(), output);
			}
		};
		return Response.ok(stream, "text/xml").build();
	}
}
