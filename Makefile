.PHONY: all dist clean

AAR_VERSION=68.6.0

webrtc-build:
	go build -o webrtc-build cmd/main.go

all: webrtc-build

dist:
	./webrtc-build selfdist

clean:
	rm -rf webrtc-build sora-webrtc-build-*

aar:
	rm -f sora-webrtc-$(AAR_VERSION)-android.zip
	docker build --rm -t sora-webrtc-build/docker-aar docker-aar
	(docker rm aar-container > /dev/null 2>&1 ; true)
	docker run --name aar-container sora-webrtc-build/docker-aar /bin/true
	docker cp aar-container:/build/sora-webrtc-$(AAR_VERSION)-android.zip .
	docker rm aar-container
