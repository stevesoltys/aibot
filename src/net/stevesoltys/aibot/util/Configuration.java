/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.stevesoltys.aibot.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Steve
 */
public class Configuration {

    private static final Configuration INSTANCE = new Configuration();
    private final String CONFIGURATION_FILE = "./data/config.ini";
    private final Properties properties = new Properties();

    public static Configuration getInstance() {
        return INSTANCE;
    }

    public void load() {
        try {
            properties.load(new FileInputStream(CONFIGURATION_FILE));
        } catch (IOException ex) {
            Logger.getLogger(Configuration.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public Properties getProperties() {
        return properties;
    }
}
