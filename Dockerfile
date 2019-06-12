FROM lionzxy/google-android-emulator:latest

COPY run-emulator /run-emulator
RUN chmod +x /run-emulator

CMD ["/run-emulator"]

