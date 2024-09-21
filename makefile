.PHONY: install

install:
	kubectl apply -k install

reconcile: install
	flux reconcile helmrelease -n flux-system
