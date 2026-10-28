package com.practice.ui.what_to_mine;

import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        final int themeMode = NativeThemeSync.readMode(this);
        try {
            NativeThemeSync.applyApplicationMode(this, themeMode);
        } catch (RuntimeException error) {
            Log.w("WhatToMineTheme", "Could not restore the Android appearance mode", error);
        }
        super.onCreate(savedInstanceState);
        NativeThemeSync.applyWindowBackground(this, themeMode);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Flutter's splash draws the same coin in the same place, so remove the system
            // splash at once instead of the default icon fade-out and reveal animation.
            getSplashScreen().setOnExitAnimationListener(splashScreenView -> {
                splashScreenView.remove();
                updateSystemUiOverlays();
            });
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
                "ru.vokarpenko.what_to_mine/theme").setMethodCallHandler((call, result) -> {
            if (!"setThemeMode".equals(call.method)) {
                result.notImplemented();
                return;
            }
            final Object value = call.argument("mode");
            if (!(value instanceof Integer) || !NativeThemeSync.isValidMode((Integer) value)) {
                result.error("invalid_theme_mode", "Expected system=0, light=1, or dark=2", null);
                return;
            }
            try {
                NativeThemeSync.saveAndApply(this, (Integer) value);
                result.success(null);
            } catch (RuntimeException error) {
                result.error("theme_sync_failed", "Could not apply the Android appearance mode", null);
            }
        });
    }
}
