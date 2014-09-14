package net.shiver.aibot.util.plugin;

import org.jruby.Ruby;
import org.jruby.embed.ScriptingContainer;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * A {@link PluginEnvironment} which uses Ruby.
 *
 * @author Graham
 */
public final class RubyPluginEnvironment implements PluginEnvironment {

    /**
     * The scripting container.
     */
    private final ScriptingContainer container = new ScriptingContainer();

    /**
     * Creates and bootstraps the Ruby plugin environment.
     *
     * @throws java.io.IOException if an I/O error occurs during bootstrapping.
     */
    public RubyPluginEnvironment() throws IOException {
        Ruby.setThreadLocalRuntime(Ruby.getGlobalRuntime());
        parseBootstrapper();
    }

    /**
     * Parses the bootstrapper.
     *
     * @throws java.io.IOException if an I/O error occurs.
     */
    private void parseBootstrapper() throws IOException {
        File f = new File("./data/plugins/bootstrap.rb");
        InputStream is = new FileInputStream(f);
        try {
            parse(is, f.getAbsolutePath());
        } finally {
            is.close();
        }
    }

    @Override
    public void parse(InputStream is, String name) {
        container.runScriptlet(is, name);
    }

    @Override
    public void setContext(PluginContext context) {
        container.put("$ctx", context);
    }
}
