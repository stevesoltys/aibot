package net.shiver.aibot.util.plugin;

import org.xml.sax.SAXException;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

/**
 * A class which manages plugins.
 *
 * @author Graham
 */
public final class PluginManager {

    /**
     * The plugin context.
     */
    private final PluginContext context;

    /**
     * Creates the plugin manager.
     *
     * @param context The plugin context.
     */
    public PluginManager(PluginContext context) {
        this.context = context;
    }

    /**
     * Starts the plugin system by finding and loading all the plugins.
     *
     * @throws org.xml.sax.SAXException if a SAX error occurs.
     * @throws java.io.IOException if an I/O error occurs.
     * @throws DependencyException if a dependency could not be resolved.
     */
    public void start() throws IOException, SAXException, DependencyException {
        Map<String, PluginMetaData> plugins = createMap(findPlugins());
        Set<PluginMetaData> started = new HashSet<>();

        PluginEnvironment env = new RubyPluginEnvironment(); // TODO isolate plugins if possible in the future!
        env.setContext(context);

        for (PluginMetaData plugin : plugins.values()) {
            start(env, plugin, plugins, started);
        }
    }

    /**
     * Finds plugins and loads their meta data.
     *
     * @return A collection of plugin meta data objects.
     * @throws java.io.IOException if an I/O error occurs.
     * @throws org.xml.sax.SAXException if a SAX error occurs.
     */
    private Collection<PluginMetaData> findPlugins() throws IOException, SAXException {
        Collection<PluginMetaData> plugins = new ArrayList<PluginMetaData>();
        File dir = new File("./data/plugins");
        for (File plugin : dir.listFiles()) {
            if (plugin.isDirectory() && !plugin.getName().startsWith(".")) {
                File xml = new File(plugin, "plugin.xml");
                if (xml.exists()) {
                    try (InputStream is = new FileInputStream(xml)) {
                        PluginMetaDataParser parser = new PluginMetaDataParser(is);
                        plugins.add(parser.parse());
                    }
                }
            }
        }
        return Collections.unmodifiableCollection(plugins);
    }

    /**
     * Starts a specific plugin.
     *
     * @param env The environment.
     * @param plugin The plugin.
     * @param plugins The plugin map.
     * @param started A set of started plugins.
     * @throws DependencyException if a dependency error occurs.
     * @throws java.io.IOException if an I/O error occurs.
     */
    private void start(PluginEnvironment env, PluginMetaData plugin, Map<String, PluginMetaData> plugins, Set<PluginMetaData> started) throws DependencyException, IOException {
        // TODO check for cyclic dependencies! this way just won't cut it, we need an exception
        if (started.contains(plugin)) {
            return;
        }
        started.add(plugin);

        for (String dependencyId : plugin.getDependencies()) {
            PluginMetaData dependency = plugins.get(dependencyId);
            if (dependency == null) {
                throw new DependencyException("Unresolved dependency: " + dependencyId + ".");
            }

            start(env, plugin, plugins, started);
        }

        String[] scripts = plugin.getScripts();

        for (String script : scripts) {
            File f = new File("./data/plugins/" + plugin.getId() + "/" + script); // TODO get from metadata obj?
            InputStream is = new FileInputStream(f);
            env.parse(is, f.getAbsolutePath());
        }
    }

    /**
     * Creates a plugin map from a collection.
     *
     * @param plugins The plugin collection.
     * @return The plugin map.
     */
    private Map<String, PluginMetaData> createMap(Collection<PluginMetaData> plugins) {
        Map<String, PluginMetaData> map = new HashMap<String, PluginMetaData>();
        for (PluginMetaData plugin : plugins) {
            map.put(plugin.getId(), plugin);
        }
        return Collections.unmodifiableMap(map);
    }
}
