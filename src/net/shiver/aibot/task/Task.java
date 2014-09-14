/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.shiver.aibot.task;

import java.util.concurrent.TimeUnit;

/**
 * @author Steve
 */
public abstract class Task implements Runnable {

    private long expiryTime;

    public Task() {
        this.expiryTime = -1;
    }

    public Task(long expiry, TimeUnit unit) {
        this.expiryTime = System.currentTimeMillis() + TimeUnit.MILLISECONDS.convert(expiry, unit);
    }

    public boolean expired() {
        return expiryTime != -1 && System.currentTimeMillis() >= expiryTime;
    }

    public void stop() {
        expiryTime = System.currentTimeMillis();
    }
}
