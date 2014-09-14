package net.shiver.aibot.util.plugin;


import net.shiver.aibot.event.EventHandler;
import net.shiver.aibot.event.EventManager;

/**
 *
 * @author Steve
 */
public final class PluginContext {

    public void addEventHandler(Class evt, EventHandler handler) {
        EventManager.getInstance().addEventHandler(evt, handler);
    }
}
