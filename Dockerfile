FROM lionzxy/google-android-emulator:latest

ENV VERSION_SDK_TOOLS "8092744_latest"
ENV CMDLINE_TOOLS "${ANDROID_HOME}/../cmdline-tools"
ENV PATH "$PATH:${CMDLINE_TOOLS}/cmdline-tools"
ENV PATH "$PATH:${CMDLINE_TOOLS}/cmdline-tools/bin"
ENV PATH "$PATH:/android/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-11-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc-s1 \
      lib32ncurses6 \
      lib32z1 \
      zip \
      unzip \
      locales \
      cowsay \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# GitLab injects the username as ENV-variable which will crash a gradle-build.
# Workaround by adding unicode-support.
# See
# https://github.com/gradle/gradle/issues/3117#issuecomment-336192694
# https://github.com/tianon/docker-brew-debian/issues/45
RUN rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip && \
    unzip /sdk.zip -d $CMDLINE_TOOLS && \
    rm -v /sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license

ADD packages.txt $ANDROID_HOME
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  sdkmanager --update

RUN yes | sdkmanager --licenses

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < $ANDROID_HOME/packages.txt && \
    sdkmanager ${PACKAGES}
RUN sdkmanager --update

COPY run-emulator /run-emulator
RUN chmod +x /run-emulator
#CMD ["/run-emulator"]

