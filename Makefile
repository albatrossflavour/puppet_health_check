all:
	${MAKE} test

install_centos6:
	bundle exec rake 'litmus:provision_list[travis_el6]'

install_centos7:
	bundle exec rake 'litmus:provision_list[travis_el7]'

install_debian:
	bundle exec rake 'litmus:provision_list[travis_deb]'

install_ubuntu:
	bundle exec rake 'litmus:provision_list[travis_ubuntu]'

install_vagrant:
	bundle exec rake 'litmus:provision_list[vagrant]'

install_module:
	bundle exec rake litmus:install_module

test:
	${MAKE} validate
	${MAKE} unit
	${MAKE} acceptance
	${MAKE} documentation

validate:
	bundle exec rake metadata_lint
	bundle exec rake syntax
	bundle exec rake validate
	bundle exec rake rubocop
	bundle exec rake check:git_ignore

unit:
	bundle exec rake spec

acceptance:
	${MAKE} test_puppet5
	${MAKE} test_puppet6

test_puppet6:
	${MAKE} install_centos6
	bundle exec rake litmus:install_agent[puppet6]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown
	${MAKE} install_centos7
	bundle exec rake litmus:install_agent[puppet6]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown
	${MAKE} install_ubuntu
	bundle exec rake litmus:install_agent[puppet6]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} install_debian
	bundle exec rake litmus:install_agent[puppet6]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown
	${MAKE} install_vagrant
	bundle exec rake litmus:install_agent[puppet6]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown

test_puppet5:
	${MAKE} install_centos6
	bundle exec rake litmus:install_agent[puppet5]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown
	${MAKE} install_centos7
	bundle exec rake litmus:install_agent[puppet5]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown
	${MAKE} install_ubuntu
	bundle exec rake litmus:install_agent[puppet5]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown
	${MAKE} install_debian
	bundle exec rake litmus:install_agent[puppet5]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown
	${MAKE} install_vagrant
	bundle exec rake litmus:install_agent[puppet5]
	${MAKE} install_module
	bundle exec rake litmus:acceptance:parallel
	${MAKE} teardown

documentation:
	bundle exec puppet strings generate --format=markdown

teardown:
	bundle exec rake litmus:tear_down

shell:
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost -p 2222
