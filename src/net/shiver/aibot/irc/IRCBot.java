/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.shiver.aibot.irc;

import net.shiver.aibot.event.impl.CommandEvent;
import net.shiver.aibot.event.impl.ReceiveMessageEvent;
import net.shiver.aibot.task.Task;
import net.shiver.aibot.task.TaskManager;
import net.shiver.aibot.util.Configuration;
import net.shiver.aibot.event.EventManager;
import net.shiver.ircbot.Bot;
import net.shiver.ircbot.event.impl.*;
import net.shiver.ircbot.net.Session;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Steve
 */
public class IRCBot extends Bot {

    private static final String NICK = "aibot";
    private static final String USER = "aibot";
    private Map<String, Object> attributes = new HashMap<>();
    private Map<Session, String> nicks = new HashMap<>();

    public void init() {
        EventManager.getInstance().init();
    }

    @Override
    public void onException(Session session, IOException exception) {
    }

    @Override
    public void onConnect(ConnectionEvent event) {
        if (!event.isDisconnected()) {
            String nick = Configuration.getInstance().getProperties().getProperty(event.getSession().getHost() + "_nick");
            String user = Configuration.getInstance().getProperties().getProperty(event.getSession().getHost() + "_user");
            String password = Configuration.getInstance().getProperties().getProperty(event.getSession().getHost() + "_pass");
            if (nick != null) {
                nicks.put(event.getSession(), nick);
                sendNick(event.getSession(), nick);
                if (user != null) {
                    sendUser(event.getSession(), user);
                } else {
                    sendUser(event.getSession(), nick);
                }
                if (password != null) {
                    sendPassword(event.getSession(), password);
                }
            } else {
                nicks.put(event.getSession(), NICK);
                sendNick(event.getSession(), NICK);
                sendUser(event.getSession(), USER);
            }

        } else {
            try {
                this.connect(event.getSession().getHost(), event.getSession().getPort());
            } catch (IOException ex) {
                Logger.getLogger(IRCBot.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public void onUserJoin(UserJoinEvent event) {
    }

    @Override
    public void onUserPart(UserPartEvent event) {
    }

    @Override
    public void onUserKick(UserKickEvent event) {
        if (event.getNick().equals(nicks.get(event.getSession()))) {
            this.joinChannel(event.getSession(), event.getChannel());
        }
    }

    @Override
    public void onRead(ReadEvent event) {
    }

    @Override
    public void onChat(final ChatEvent event) {
        TaskManager.getInstance().submit(new Task(10, TimeUnit.SECONDS) {
            @Override
            public void run() {
                if (event.getLine().toLowerCase().startsWith("!")) {
                    try {
                        int marker = event.getLine().indexOf(" ") > 0 ? event.getLine().indexOf(" ") : event.getLine().length();
                        String command = event.getLine().substring(1, marker);
                        String[] args = new String[]{};
                        if (marker != event.getLine().length()) {
                            args = event.getLine().substring(event.getLine().indexOf(" ") + 1).split(" ");
                        }
                        EventManager.getInstance().submit(IRCBot.this, new CommandEvent(event, command, args));
                    } catch (Exception ex) {
                        Logger.getLogger(IRCBot.class.getName()).log(Level.SEVERE, null, ex);
                        sendMessage(event.getSession(), event.getChannel(), "Command error!");
                    }
                    return;
                }
                EventManager.getInstance().submit(IRCBot.this, new ReceiveMessageEvent(event));
            }
        });
    }

    @Override
    public void onServerResponse(ServerResponseEvent event) {
        if (event.getCode() == 3) {
            String[] channels = Configuration.getInstance().getProperties().
                    getProperty(event.getSession().getHost() + "_channels").
                    split(",");
            for (String channel : channels) {
                System.out.println("joining  " + channel);
                joinChannel(event.getSession(), "#" + channel);
            }
            String oper_user = Configuration.getInstance().getProperties().
                    getProperty(event.getSession().getHost() + "_oper_user");
            String oper_pass = Configuration.getInstance().getProperties().
                    getProperty(event.getSession().getHost() + "_oper_pass");
            if (oper_user != null && oper_pass != null) {
                writeLine(event.getSession(), "OPER " + oper_user + " " + oper_pass);
            }
        }
    }

    /**
     * Removes an attribute.<br /> WARNING: unchecked cast, be careful!
     *
     * @param <T> The type of the value.
     * @param key The key.
     * @return The old value.
     */
    @SuppressWarnings("unchecked")
    public <T> T removeAttribute(String key) {
        return (T) attributes.remove(key);
    }

    /**
     * Removes all attributes.
     */
    public void removeAllAttributes() {
        if (attributes != null && attributes.size() > 0 && attributes.keySet().size() > 0) {
            attributes = new HashMap<String, Object>();
        }
    }

    /**
     * Sets an attribute.<br /> WARNING: unchecked cast, be careful!
     *
     * @param <T>   The type of the value.
     * @param key   The key.
     * @param value The value.
     * @return The old value.
     */
    @SuppressWarnings("unchecked")
    public <T> T setAttribute(String key, T value) {
        return (T) attributes.put(key, value);
    }

    /**
     * Gets an attribute.<br /> WARNING: unchecked cast, be careful!
     *
     * @param <T> The type of the value.
     * @param key The key.
     * @return The value.
     */
    @SuppressWarnings("unchecked")
    public <T> T getAttribute(String key) {
        return (T) attributes.get(key);
    }

    /**
     * Gets the attribute list.
     *
     * @return the list
     */
    public Map<String, Object> getAttributes() {
        return attributes;
    }

    public Map<Session, String> getNicks() {
        return nicks;
    }
}
