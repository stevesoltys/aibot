/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.stevesoltys.aibot.event.impl;


import net.stevesoltys.aibot.event.Event;
import net.shiver.ircbot.event.impl.ChatEvent;

/**
 *
 * @author Stephen
 */
public class CommandEvent implements Event {

    private String command;
    private String[] args;
    private ChatEvent event;

    public CommandEvent(ChatEvent event, String command, String... args) {
        this.event = event;
        this.command = command;
        this.args = args;
    }
    
    public ChatEvent getChatEvent() {
        return event;
    }
    
    public String getCommand(){
        return command;
    }
    
    public String[] getArgs() {
        return args;
    }
}
