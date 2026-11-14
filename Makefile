.PHONY: help install-deps codegen clean

help:
	@echo "Available commands:"
	@echo "  make codegen        - Generate FRB bindings and restore the Native Assets loader"
	@echo "  make install-deps   - Install the pinned FRB code generator"
	@echo "  make clean          - Clean build artifacts"

codegen:
	./tool/generate_bindings.sh

clean:
	cd rust && cargo clean
	fvm flutter clean

install-deps:
	cargo +1.100.0 install flutter_rust_bridge_codegen --version 2.13.0 --locked
