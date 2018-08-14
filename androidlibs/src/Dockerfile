FROM openjdk:8

# configure SDK version
ENV SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" \
    ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_VERSION=26 \
    ANDROID_BUILD_TOOLS_VERSION=26.0.2

# accept all licences
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses > /dev/null 2>&1

# install android build tool and libraries
RUN $ANDROID_HOME/tools/bin/sdkmanager --update > /dev/null 2>&1
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools" > /dev/null 2>&1

# install gradle
RUN wget -q https://services.gradle.org/distributions/gradle-4.1-bin.zip \
    && unzip gradle-4.1-bin.zip -d /opt \
    && rm gradle-4.1-bin.zip

ENV GRADLE_HOME /opt/gradle-4.1
ENV PATH $PATH:/opt/gradle-4.1/bin

# import src copy
RUN mkdir /code
WORKDIR /code
COPY . /code

# gradle build
RUN gradle build