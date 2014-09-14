/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.stevesoltys.aibot.task;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 *
 * @author Steve
 */
public final class TaskManager {

    private static final TaskManager INSTANCE = new TaskManager();
    private Map<Task, Future<?>> tasks = new HashMap<>();
    private final ScheduledExecutorService service;
    private final ScheduledExecutorService taskService;

    public static TaskManager getInstance() {
        return INSTANCE;
    }

    public TaskManager() {
        this.service = Executors.newScheduledThreadPool(1);
        this.taskService = Executors.newScheduledThreadPool(1);
        taskService.scheduleAtFixedRate(new Task() {
            @Override
            public void run() {
                Task[] tsks = (Task[]) tasks.keySet().toArray();
                Future<?>[] futures = (Future<?>[]) tasks.entrySet().toArray();
                for (int i = 0; i < tsks.length; i++) {
                    if (tsks[i].expired()) {
                        kill(tsks[i]);
                    }
                    if (futures[i].isDone()) {
                        tasks.remove(tsks[i]);
                    }
                }
            }
        }, 0, 5, TimeUnit.SECONDS);
    }

    public void schedulePeriodicTask(Task task, long initialDelay, long interval, TimeUnit timeUnit) {
        tasks.put(task, service.scheduleAtFixedRate(task, initialDelay, interval, timeUnit));
    }

    public void schedulePeriodicTask(Task task, long interval, TimeUnit timeUnit) {
        tasks.put(task, service.scheduleAtFixedRate(task, 0, interval, timeUnit));
    }

    public void schedule(Task task, long delay, TimeUnit timeUnit) {
        tasks.put(task, service.schedule(task, delay, timeUnit));
    }

    public void submit(Task task) {
        tasks.put(task, service.submit(task));
    }

    public void cancel(Task task) {
        tasks.get(task).cancel(false);
    }

    public void kill(Task task) {
        tasks.get(task).cancel(true);
    }
}
