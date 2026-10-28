package com.practice.ui.what_to_mine;

import android.os.Build;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Flutter's splash draws the same coin in the same place, so remove the system
            // splash at once instead of the default icon fade-out and reveal animation.
            getSplashScreen().setOnExitAnimationListener(splashScreenView -> {
                splashScreenView.remove();
                updateSystemUiOverlays();
            });
        }
    }
}
