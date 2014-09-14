/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.stevesoltys.aibot.util;

import net.htmlparser.jericho.Element;
import net.htmlparser.jericho.Source;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Steve
 */
public class InternetMovieDatabaseUtility {

    private static final InternetMovieDatabaseUtility INSTANCE = new InternetMovieDatabaseUtility();
    private static final String API_URL = "http://deanclatworthy.com/imdb/";
    private static final String DATA_TYPE = "xml";

    public static InternetMovieDatabaseUtility getInstance() {
        return INSTANCE;
    }

    public String[] query(String query) throws IOException {
        List<String> results = new ArrayList<String>();
        Source source = new Source(new URL(API_URL + "?type=" + DATA_TYPE + "&q=" + query));
        source.fullSequentialParse();
        for (Element element : source.getAllElements()) {
            if (element.getName().equals("error")) {
                for (Element child_element : element.getChildElements()) {
                    if (child_element.getName().equals("error")) {
                        results.add("[Error: " + child_element.getContent().toString() + "]");
                    }
                }
                break;
            } else if (element.getName().equals("imdburl")) {
                results.add("[URL: " + element.getContent().toString() + "]");
            } else if (element.getName().equals("title")) {
                results.add("[Title: " + element.getContent().toString() + "]");
            } else if (element.getName().equals("genres")) {
                results.add("[Genres: " + element.getContent().toString() + "]");
            } else if (element.getName().equals("languages")) {
                results.add("[Languages: " + element.getContent().toString() + "]");
            } else if (element.getName().equals("country")) {
                results.add("[Countries: " + element.getContent().toString() + "]");
            } else if (element.getName().equals("rating")) {
                results.add("[Rating: " + element.getContent().toString() + "]");
            } else if (element.getName().equals("year")) {
                results.add("[Year: " + element.getContent().toString() + "]");
            } else if (element.getName().equals("runtime")) {
                results.add("[Runtime: " + element.getContent().toString() + "]");
            }
        }
        return results.toArray(new String[results.size()]);
    }
}
