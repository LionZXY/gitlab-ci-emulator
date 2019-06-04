FROM jangrewe/gitlab-ci-android:latest

RUN apt-get update -y && apt-get install wget -y

RUN cd $ANDROID_HOME/tools/bin && \
        ./sdkmanager "system-images;android-28;google_apis;x86" && \
        ./sdkmanager --licenses

RUN echo no | $ANDROID_HOME/tools/bin/avdmanager create avd -n notifybest -k "system-images;android-28;google_apis;x86"

COPY android-wait-for-emulator /android-wait-for-emulator
COPY run-emulator /run-emulator

RUN chmod +x android-wait-for-emulator
RUN chmod +x run-emulator

