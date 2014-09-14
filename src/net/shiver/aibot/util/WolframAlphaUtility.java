/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.shiver.aibot.util;

import com.wolfram.alpha.WAEngine;
import com.wolfram.alpha.WAException;
import com.wolfram.alpha.WAQueryResult;

/**
 *
 * @author Steve
 */
public class WolframAlphaUtility {

    private static final WolframAlphaUtility INSTANCE = new WolframAlphaUtility();
    private static final String APP_ID = "LV2XXT-YAPHT9G57T";
    private final WAEngine engine = new WAEngine();

    public static WolframAlphaUtility getInstance() {
        return INSTANCE;
    }

    public WolframAlphaUtility() {
        engine.setAppID(APP_ID);
        engine.addFormat("plaintext");
    }

    public WAQueryResult query(String input) throws WAException {
        return engine.performQuery(engine.createQuery(input));
    }

}
