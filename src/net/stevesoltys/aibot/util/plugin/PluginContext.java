package net.stevesoltys.aibot.util.plugin;


import net.stevesoltys.aibot.event.EventHandler;
import net.stevesoltys.aibot.event.EventManager;

/**
 *
 * @author Steve
 */
public final class PluginContext {

    public void addEventHandler(Class evt, EventHandler handler) {
        EventManager.getInstance().addEventHandler(evt, handler);
    }
}
