package de.tuebingen.uni.sfs.cmdi2marc;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.security.AccessControlException;
import java.util.Iterator;
import java.util.Properties;
import javax.ws.rs.core.MediaType;
import javax.xml.XMLConstants;
import javax.xml.namespace.NamespaceContext;
import javax.xml.namespace.QName;
import javax.xml.transform.OutputKeys;
import javax.xml.xquery.XQConnection;
import javax.xml.xquery.XQDataSource;
import javax.xml.xquery.XQPreparedExpression;
import javax.xml.xquery.XQResultSequence;
import net.sf.saxon.xqj.SaxonXQDataSource;
import org.apache.commons.io.FilenameUtils;

import javax.xml.xpath.*;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;

import javax.xml.parsers.ParserConfigurationException;
import net.sf.saxon.expr.XPathContext;
import org.apache.commons.io.IOUtils;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;


public class CMDICast {

	public static void main(String[] args) throws Exception {
		test();
	}

	public static void test() throws Exception {
		File result = castFile("annotated_english_gigaword.cmdi");
		System.out.println("first done");
		castFile("annotated_english_gigaword.cmdi");
		System.out.println("second done");
		castFile("annotated_english_gigaword.cmdi");
		System.out.println("third done");
	}

	public static File castFile(String cmdifilename) throws Exception {
		return castFile(new File(cmdifilename));
	}

	public static InputStream getInputStream(String filename) {
		try {
			return new FileInputStream(filename);
		} catch (FileNotFoundException | AccessControlException xc) { //ignore
		}
		try {
			return new FileInputStream("src/main/webapp/" + filename);
		} catch (FileNotFoundException | AccessControlException xc) { //ignore
		}

		ClassLoader cl = Thread.currentThread().getContextClassLoader();
		InputStream is = null;
		try {
			is = cl.getResourceAsStream(filename);
		} catch (AccessControlException xc) { //ignore
			xc.printStackTrace();
		}
		return (is != null) ? is : cl.getResourceAsStream("../../" + filename);
	}

	public static File castFile(File cmdifile) throws Exception {
		XQDataSource ds = new SaxonXQDataSource();
		XQConnection conn = ds.getConnection();
//		System.out.println("Cmdi2Marc: casting file " + cmdifile.getAbsolutePath());

		try (   InputStream cmdi2marcStream      = getInputStream("cmdi2marc.xquery");
			InputStream cmdiInstanceStream = new FileInputStream(cmdifile);
                        InputStream cmdiFileStream     = new FileInputStream(cmdifile) )
                    
                     {    
			// get the schemaLocation using xpath
			XPathFactory xPathfactory = XPathFactory.newInstance();
			XPath xpath = xPathfactory.newXPath();
                        
                        /*
                        // there's no default implementation for NamespaceContext...seems kind of silly, no?
                        xpath.setNamespaceContext(new NamespaceContext() {
                              public String getNamespaceURI(String prefix) {
                                 if (prefix == null) throw new NullPointerException("Null prefix");
                                 else if ("oai".equals(prefix)) return "http://www.openarchives.org/OAI/2.0/";
                                 else if ("cmd".equals(prefix)) return "http://www.clarin.eu/cmd/";
                                 else if ("xml".equals(prefix)) return XMLConstants.XML_NS_URI;
                                   return XMLConstants.NULL_NS_URI;
                                }

                              // This method isn't necessary for XPath processing.
                              public String getPrefix(String uri) {
                                 throw new UnsupportedOperationException();
                              }

                              // This method isn't necessary for XPath processing either.
                              public Iterator getPrefixes(String uri) {
                                 throw new UnsupportedOperationException();
                             }
                        });

                        String oai_check_string = "//*[namespace-uri()='http://www.openarchives.org/OAI/2.0/' or @*[namespace-uri()='http://www.openarchives.org/OAI/2.0/']]";
                        */
                        
                        // works: XPathExpression schemaLocation = xpath.compile("string(//@*[local-name()='schemaLocation'])");
                        XPathExpression schemaLocation = xpath.compile("string(//*[local-name()=\"MdProfile\"]/text())");

                        
                        //XPathContext oai_ctx     = new XPathContext("xsi", "http://www.openarchives.org/OAI/2.0/") {};
                        //XPathContext clarin_ctx  = new XPathContext("xsi", "http://www.clarin.eu/cmd/");
                        // Nodes nodes = root.query("//html:head", ctx );
                        
                        // In case we have no envelope, we can do the following:
                        String pureString = "string(//CMD/Header/MdProfile)";
                        // In case we have an OAI-envelope, schemaLocation would return the OAI schema location...
                        String oaiString = "string(/OAI-PMH/GetRecord[1]/record[1]/metadata[1]/*[namespace-uri()='http://www.clarin.eu/cmd/' and local-name()='CMD'][1]/*[namespace-uri()='http://www.clarin.eu/cmd/' and local-name()='Header'][1]/*[namespace-uri()='http://www.clarin.eu/cmd/' and local-name()='MdProfile'][1])";
                                
            
			// try to parse the cmdifile
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                        factory.setNamespaceAware(true);
                        DocumentBuilder builder = factory.newDocumentBuilder();
			Document cmdiFileDocument = builder.parse(cmdiFileStream);
			
			String schemaLocationString = (String) schemaLocation.evaluate(cmdiFileDocument, XPathConstants.STRING);
			System.out.println("schema location found -" + schemaLocationString + "- in cmdi instance " + cmdifile.getName());	
                        
                        if (schemaLocationString.endsWith("/xsd")) {
                            schemaLocationString = schemaLocationString.substring(0, schemaLocationString.length() - 4);
                        }
                        
                        String registryPrefix = "http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/";
                        
                        // load the dynamic schema
                        InputStream dynamicSchemaStream = new URL(registryPrefix + schemaLocationString +"/xml").openStream();
                    
			// now apply the xquery
			XQPreparedExpression expr = conn.prepareExpression(cmdi2marcStream);
                        expr.bindDocument(new QName("cmdCCSL"),   dynamicSchemaStream, null, null);
			expr.bindDocument(new QName("cmdInstancepath"), cmdiInstanceStream,  null, null);
			XQResultSequence result = expr.executeQuery(); 

			Properties props = new Properties();
			props.setProperty(OutputKeys.METHOD, "xml");
			props.setProperty(OutputKeys.INDENT, "yes");
			props.setProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
			props.setProperty(OutputKeys.STANDALONE, "yes");
			props.setProperty(OutputKeys.MEDIA_TYPE, MediaType.APPLICATION_XML);

			String name = FilenameUtils.removeExtension(cmdifile.getName());
			File output = new File(cmdifile.getParent(), name + ".marc.xml");
			BufferedOutputStream outputStream = new BufferedOutputStream(new FileOutputStream(output));
			result.writeSequence(outputStream, props);
			return output;
		}
	}
}
