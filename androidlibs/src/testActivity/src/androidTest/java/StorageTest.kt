import androidx.test.annotation.UiThreadTest
import androidx.test.espresso.Espresso.*
import androidx.test.espresso.action.ViewActions.*
import androidx.test.espresso.assertion.ViewAssertions.*
import androidx.test.espresso.matcher.ViewMatchers.*
import androidx.test.filters.SdkSuppress
import androidx.test.internal.runner.junit4.AndroidJUnit4ClassRunner
import androidx.test.rule.ActivityTestRule
import ch.papers.securestorage.activityrunner.R
import ch.papers.securestorage.activityrunner.SecureStorageTestActivity
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**s
 * Created by Dominik on 19.01.2018.
 */

@RunWith(AndroidJUnit4ClassRunner::class)
class StorageTest {

    @get:Rule
    val activityRule = ActivityTestRule<SecureStorageTestActivity>(SecureStorageTestActivity::class.java)

    @Before
    fun setup() {
        // destroy
        onView(withId(R.id.buttonDestroy)).perform(click())
    }

    @Test
    @SdkSuppress(minSdkVersion = 18, maxSdkVersion = 22)
    fun writeStringEnforcedParanoia() {
        // setup normal storage
        onView(withId(R.id.buttonNormalSetup)).perform(click())

        // click on store data button
        onView(withId(R.id.buttonStore)).perform(click())

        // fill in PW and confirm
        setupNormalStorage("test-password")

        // confirm PW upon alert
        onView(withId(R.id.password)).perform(click())
        onView(withId(R.id.password)).perform(typeText("test-password"))
        onView(withText(R.string.paranoia_input_alert_unlock_button)).perform(click())

        // check if successful toast pops up
        ToastMatcher.Companion.onToast("Data written!").check(matches(isDisplayed()))
    }

    @Test
    @SdkSuppress(minSdkVersion = 18, maxSdkVersion = 22)
    fun readStringEnforcedParanoia() {
        // setup normal storage
        onView(withId(R.id.buttonNormalSetup)).perform(click())

        // click on store data button
        onView(withId(R.id.buttonStore)).perform(click())

        // fill in PW and confirm
        setupNormalStorage("test-password")

        // confirm PW upon alert
        onView(withId(R.id.password)).perform(click())
        onView(withId(R.id.password)).perform(typeText("test-password"))
        onView(withText(R.string.paranoia_input_alert_unlock_button)).perform(click())

        // click on store data button
        onView(withId(R.id.buttonRead)).perform(click())

        // confirm PW upon alert
        onView(withId(R.id.password)).perform(click())
        onView(withId(R.id.password)).perform(typeText("test-password"))
        onView(withText(R.string.paranoia_input_alert_unlock_button)).perform(click())

        // check if successful toast pops up
        ToastMatcher.Companion.onToast("Data read: testData").check(matches(isDisplayed()))
    }

    private fun setupNormalStorage(password: String) {
        onView(withId(R.id.password)).perform(click())
        onView(withId(R.id.password)).perform(typeText(password))

        onView(withId(R.id.password_confirmation)).perform(click())
        onView(withId(R.id.password_confirmation)).perform(typeText(password))

        onView(withText(R.string.paranoia_input_alert_positive_button)).perform(click())
    }

}