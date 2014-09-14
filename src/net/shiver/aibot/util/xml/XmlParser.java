package net.shiver.aibot.util.xml;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.util.Stack;

/**
 * A simple XML parser which uses the internal {@link org.xml.sax} API to
 * create a tree of {@link XmlNode} objects.
 * @author Graham
 */
public final class XmlParser {

	/**
	 * A class which handles SAX events.
	 * @author Graham
	 */
	private final class XmlHandler extends DefaultHandler {

		@Override
		public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
			XmlNode next = new XmlNode(localName);

			if (rootNode == null) {
				rootNode = currentNode = next;
			} else {
				currentNode.addChild(next);
				nodeStack.add(currentNode);
				currentNode = next;
			}

			if (attributes != null) {
				int attributeCount = attributes.getLength();
				for (int i = 0; i < attributeCount; i++) {
					String attribLocalName = attributes.getLocalName(i);
					currentNode.setAttribute(attribLocalName, attributes.getValue(i));
				}
			}
		}

		@Override
		public void endElement(String uri, String localName, String qName) throws SAXException {
			if (!nodeStack.isEmpty()) {
				currentNode = nodeStack.pop();
			}
		}

		@Override
		public void characters(char[] ch, int start, int length) throws SAXException {
			currentNode.setValue(new String(ch, start, length));
		}

	}

	/**
	 * The {@link org.xml.sax.XMLReader} backing this {@link XmlParser}.
	 */
	private final XMLReader xmlReader;

	/**
	 * The SAX event handler.
	 */
	private final XmlHandler eventHandler;

	/**
	 * The current root node.
	 */
	private XmlNode rootNode;

	/**
	 * The current node.
	 */
	private XmlNode currentNode;

	/**
	 * The stack of nodes, which is used when traversing the document and going
	 * through child nodes.
	 */
	private Stack<XmlNode> nodeStack = new Stack<XmlNode>();

	/**
	 * Creates a new xml parser.
	 * @throws org.xml.sax.SAXException if a SAX error occurs.
	 */
	public XmlParser() throws SAXException {
		xmlReader = XMLReaderFactory.createXMLReader();
		eventHandler = this.new XmlHandler();
		init();
	}

	/**
	 * Initialises this parser.
	 */
	private void init() {
		xmlReader.setContentHandler(eventHandler);
		xmlReader.setDTDHandler(eventHandler);
		xmlReader.setEntityResolver(eventHandler);
		xmlReader.setErrorHandler(eventHandler);
	}

	/**
	 * Parses XML data from the given {@link java.io.InputStream}.
	 * @param is The {@link java.io.InputStream}.
	 * @return The root {@link XmlNode}.
	 * @throws java.io.IOException if an I/O error occurs.
	 * @throws org.xml.sax.SAXException if a SAX error occurs.
	 */
	public XmlNode parse(InputStream is) throws IOException, SAXException {
		synchronized (this) {
			return parse(new InputSource(is));
		}
	}

	/**
	 * Parses XML data from the given {@link java.io.Reader}.
	 * @param reader The {@link java.io.Reader}.
	 * @return The root {@link XmlNode}.
	 * @throws java.io.IOException if an I/O error occurs.
	 * @throws org.xml.sax.SAXException if a SAX error occurs.
	 */
	public XmlNode parse(Reader reader) throws IOException, SAXException {
		synchronized (this) {
			return parse(new InputSource(reader));
		}
	}

	/**
	 * Parses XML data from the {@link org.xml.sax.InputSource}.
	 * @param source The {@link org.xml.sax.InputSource}.
	 * @return The root {@link XmlNode}.
	 * @throws java.io.IOException if an I/O error occurs.
	 * @throws org.xml.sax.SAXException if a SAX error occurs.
	 */
	private XmlNode parse(InputSource source) throws IOException, SAXException {
		rootNode = null;
		xmlReader.parse(source);
		if (rootNode == null) {
			throw new SAXException("no root element!");
		}
		return rootNode;
	}

}
