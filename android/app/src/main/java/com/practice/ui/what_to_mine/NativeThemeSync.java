package com.practice.ui.what_to_mine;

import android.app.Activity;
import android.app.UiModeManager;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;

import org.json.JSONException;
import org.json.JSONObject;

/** Keeps Android's launch window in the same appearance mode as Flutter. */
final class NativeThemeSync {
    private static final String PREFERENCES = "what_to_mine_appearance";
    private static final String MODE = "theme_mode";
    private static Integer lastAppliedMode;

    private NativeThemeSync() {}

    static int readMode(Context context) {
        final android.content.SharedPreferences nativeSettings =
                context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        if (nativeSettings.contains(MODE)) {
            return validMode(nativeSettings.getInt(MODE, 0));
        }
        // Migration for existing installs. Read only the old appearance field;
        // the native code never reads API credentials or cached API responses.
        final String saved = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE).getString("flutter.s", null);
        if (saved != null) {
            try {
                return validMode(new JSONObject(saved).optInt("themeIndex", 0));
            } catch (JSONException ignored) {
                // A new or corrupt setting follows the phone's appearance.
            }
        }
        return 0;
    }

    static boolean isValidMode(int mode) {
        return mode >= 0 && mode <= 2;
    }

    private static int validMode(int mode) {
        return isValidMode(mode) ? mode : 0;
    }

    static void saveAndApply(Activity activity, int mode) {
        final android.content.SharedPreferences settings =
                activity.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        if (!settings.contains(MODE) || settings.getInt(MODE, 0) != mode) {
            // Finish the tiny native preference write before acknowledging a
            // theme change, including when the app is immediately force-stopped.
            if (!settings.edit().putInt(MODE, mode).commit()) {
                throw new IllegalStateException("Could not persist the appearance mode");
            }
        }
        applyApplicationMode(activity, mode);
        applyWindowBackground(activity, mode);
    }

    static void applyApplicationMode(Context context, int mode) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return;
        if (lastAppliedMode != null && lastAppliedMode == mode) return;
        final UiModeManager manager = context.getSystemService(UiModeManager.class);
        if (manager == null) return;
        final int androidMode;
        switch (mode) {
            case 1:
                androidMode = UiModeManager.MODE_NIGHT_NO;
                break;
            case 2:
                androidMode = UiModeManager.MODE_NIGHT_YES;
                break;
            default:
                // In setApplicationNightMode AUTO clears the app override
                // (UI_MODE_NIGHT_UNDEFINED), following the system configuration.
                // It must not be replaced with setNightMode, which changes the phone.
                androidMode = UiModeManager.MODE_NIGHT_AUTO;
                break;
        }
        manager.setApplicationNightMode(androidMode);
        lastAppliedMode = mode;
    }

    static void applyWindowBackground(Activity activity, int mode) {
        final Configuration configuration = new Configuration(
                activity.getResources().getConfiguration());
        final int night;
        if (mode == 1) {
            night = Configuration.UI_MODE_NIGHT_NO;
        } else if (mode == 2) {
            night = Configuration.UI_MODE_NIGHT_YES;
        } else {
            night = Resources.getSystem().getConfiguration().uiMode
                    & Configuration.UI_MODE_NIGHT_MASK;
        }
        configuration.uiMode = (configuration.uiMode & ~Configuration.UI_MODE_NIGHT_MASK) | night;
        final Context themedContext = activity.createConfigurationContext(configuration);
        activity.getWindow().setBackgroundDrawable(new ColorDrawable(
                themedContext.getColor(R.color.splash_background)));
    }
}
