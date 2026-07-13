package com.example.far_ish_bor

import android.app.Application
import com.yandex.mapkit.MapKitFactory

/**
 * Custom Application — Yandex MapKit'ni ishga tushirish uchun (ishlar xaritasi).
 * east_quest bilan bir xil init.
 */
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("a4ea036d-8925-4c9c-8360-73d09445e5a5")
    }
}
