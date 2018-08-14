package ch.papers.securestorage

import android.support.test.InstrumentationRegistry
import android.support.test.runner.AndroidJUnit4
import org.junit.Assert.*
import org.junit.Test

import org.junit.runner.RunWith
import java.util.concurrent.CountDownLatch

/**
 * Created by Dominik on 19.01.2018.
 */

@RunWith(AndroidJUnit4::class)
class StorageTest {

    @Test
    @Throws(Exception::class)
    fun readString() {
        val appContext = InstrumentationRegistry.getTargetContext()
        val waitForeverLatch = CountDownLatch(1)

        val secureStorage = Storage(appContext, "test-normal", false)

        // read data
        secureStorage.readString("test-file-key", { content ->
            assertEquals("testData", content)
            waitForeverLatch.countDown()
        }, { error ->
            fail(error.message)
            waitForeverLatch.countDown()
        }, requestAuthentication = { success ->
            success()
        })

        waitForeverLatch.await()
    }

    @Test
    @Throws(Exception::class)
    fun writeString() {
        val appContext = InstrumentationRegistry.getTargetContext()
        val waitForeverLatch = CountDownLatch(1)
        val secureStorage = Storage(appContext, "test-normal", false)

        secureStorage.writeString("test-file-key", "testData", {
            // read data
            secureStorage.readString("test-file-key", { content ->
                assertEquals("testData", content)
                waitForeverLatch.countDown()
            }, { error ->
                fail(error.message)
                waitForeverLatch.countDown()
            }, requestAuthentication = { success ->
                success()
            })
        }, { error ->
            fail(error.message)
            waitForeverLatch.countDown()
        }, requestAuthentication = { success ->
            success()
        })

        waitForeverLatch.await()
    }

}