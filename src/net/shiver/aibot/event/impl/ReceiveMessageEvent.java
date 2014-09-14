/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.shiver.aibot.event.impl;

import net.shiver.aibot.event.Event;
import net.shiver.ircbot.event.impl.ChatEvent;

/**
 * An event which is fired when a message is received in on IRC.
 *
 * @author aibot
 */
public class ReceiveMessageEvent implements Event {

    private final ChatEvent chatEvent;

    public ReceiveMessageEvent(ChatEvent event) {
        this.chatEvent = event;
    }

    public ChatEvent getChatEvent() {
        return chatEvent;
    }
}
