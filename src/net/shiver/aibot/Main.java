package net.shiver.aibot;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

import net.shiver.aibot.irc.IRCBot;
import net.shiver.aibot.util.Configuration;
import org.jdom2.JDOMException;

import java.io.IOException;
import java.util.Properties;
import java.util.logging.FileHandler;
import java.util.logging.Logger;

/**
 * @author Steve
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException, JDOMException {
        Logger.getLogger("").addHandler(new FileHandler("error.log", false));
        Configuration.getInstance().load();
        IRCBot bot = new IRCBot();
        bot.init();
        int i = 1;
        Properties properties = Configuration.getInstance().getProperties();
        while (properties.containsKey("host" + i)) {
            String server = Configuration.getInstance().getProperties().
                    getProperty("host" + i);
            int port = Integer.parseInt(Configuration.getInstance().getProperties().
                    getProperty("port" + i));
            bot.connect(server, port);
            i++;
        }
        /*  Romeo net = new Romeo(new Brain(), new StanfordParserSentenceFactory());
         Scanner scanner = new Scanner(System.in);
         while (true) {
         String line = scanner.nextLine().replaceAll("'", "");
         if (!line.isEmpty()) {
         net.learn(line);
         }
         System.out.println(net.respond(line).toString());
         }*/
    }
}
