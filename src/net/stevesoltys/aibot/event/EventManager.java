/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.stevesoltys.aibot.event;


import net.stevesoltys.aibot.util.plugin.DependencyException;
import net.stevesoltys.aibot.util.plugin.PluginContext;
import net.stevesoltys.aibot.util.plugin.PluginManager;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author Steve
 */
public class EventManager {

    private static final EventManager singleton = new EventManager();
    private final Map<Class<? extends Event>, List<EventHandler>> eventHandlers = new HashMap<Class<? extends Event>, List<EventHandler>>();
    private final PluginContext pluginContext = new PluginContext();
    private final PluginManager pluginManager = new PluginManager(pluginContext);

    public static EventManager getInstance() {
        return singleton;
    }

    public void init() {
        try {
            pluginManager.start();
        } catch (IOException | SAXException | DependencyException ex) {
            Logger.getLogger(EventManager.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @SuppressWarnings("unchecked")
    public void addEventHandler(Class evt, EventHandler handler) {
        if (!eventHandlers.containsKey(evt)) {
            eventHandlers.put(evt, new LinkedList<EventHandler>());
        }
        eventHandlers.get(evt).add(handler);
    }

    @SuppressWarnings("unchecked")
    public void submit(Object context, Event event) {
        if (!eventHandlers.containsKey(event.getClass())) {
            return;
        }
        try {
            List<EventHandler> events = new LinkedList<EventHandler>();
            events.addAll(eventHandlers.get(event.getClass()));
            for (EventHandler eh : events) {
                eh.handle(context, event);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public Map<Class<? extends Event>, List<EventHandler>> getEventHandlers() {
        return eventHandlers;
    }
}
