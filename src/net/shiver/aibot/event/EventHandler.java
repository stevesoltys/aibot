/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.shiver.aibot.event;

/**
 *
 * @author Steve
 */
public abstract class EventHandler<E extends Event> {

    public abstract void handle(Object ctx, E event);
}
