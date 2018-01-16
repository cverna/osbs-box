#!/bin/bash

# Created by argbash-init v2.5.0
# ARG_OPTIONAL_SINGLE([osbs-client-branch],[],[osbs-client git branch],[master])
# ARG_OPTIONAL_SINGLE([koji-containerbuild-branch],[],[koji-containerbuild git branch],[master])
# ARG_OPTIONAL_SINGLE([build-image],[],[builder container image],[lucarval/rhel-buildroot:latest])
# ARG_OPTIONAL_SINGLE([source-registry],[],[registry to pull parent images],[http://registry.fedoraproject.org])
# ARG_OPTIONAL_BOOLEAN([deploy],[],[start a new instance of osbs-box])
# ARG_HELP([Deploy and/or reconfigure the osbs-box instance])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.5.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info

die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

begins_with_short_option()
{
	local first_option all_short_options
	all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}



# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_osbs_client_branch="master"
_arg_koji_containerbuild_branch="master"
_arg_build_image="lucarval/rhel-buildroot:latest"
_arg_source_registry="http://registry.fedoraproject.org"
_arg_deploy=off

print_help ()
{
	printf "%s\n" "Deploy and/or reconfigure the osbs-box instance"
	printf 'Usage: %s [--osbs-client-branch <arg>] [--koji-containerbuild-branch <arg>] [--build-image <arg>] [--source-registry <arg>] [--(no-)deploy] [-h|--help]\n' "$0"
	printf "\t%s\n" "--osbs-client-branch: osbs-client git branch (default: '"master"')"
	printf "\t%s\n" "--koji-containerbuild-branch: koji-containerbuild git branch (default: '"master"')"
	printf "\t%s\n" "--build-image: builder container image (default: '"lucarval/rhel-buildroot:latest"')"
	printf "\t%s\n" "--source-registry: registry to pull parent images (default: '"http://registry.fedoraproject.org"')"
	printf "\t%s\n" "--deploy,--no-deploy: start a new instance of osbs-box (off by default)"
	printf "\t%s\n" "-h,--help: Prints help"
}

parse_commandline ()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--osbs-client-branch)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_osbs_client_branch="$2"
				shift
				;;
			--osbs-client-branch=*)
				_arg_osbs_client_branch="${_key##--osbs-client-branch=}"
				;;
			--koji-containerbuild-branch)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_koji_containerbuild_branch="$2"
				shift
				;;
			--koji-containerbuild-branch=*)
				_arg_koji_containerbuild_branch="${_key##--koji-containerbuild-branch=}"
				;;
			--build-image)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_build_image="$2"
				shift
				;;
			--build-image=*)
				_arg_build_image="${_key##--build-image=}"
				;;
			--source-registry)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_source_registry="$2"
				shift
				;;
			--source-registry=*)
				_arg_source_registry="${_key##--source-registry=}"
				;;
			--no-deploy|--deploy)
				_arg_deploy="on"
				test "${1:0:5}" = "--no-" && _arg_deploy="off"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

echo "Value of --osbs-client-branch: $_arg_osbs_client_branch"
echo "Value of --koji-containerbuild-branch: $_arg_koji_containerbuild_branch"
echo "Value of --build-image: $_arg_build_image"
echo "Value of --source-registry: $_arg_source_registry"
echo "deploy is $_arg_deploy"

set -euo pipefail

if [ "${_arg_deploy}" = on ]
then
    ./osbs-box.py up --distro rhel7 \
      --repo-url http://download.eng.bos.redhat.com/rcm-guest/users/lucarval/buildroot_osbs_box.repo
fi

OSBS_CLIENT_BRANCH=$_arg_osbs_client_branch
KOJI_CONTAINERBUILD_BRANCH=$_arg_koji_containerbuild_branch

BUILDROOT=$_arg_build_image
# BUILDROOT='brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rcm/buildroot:1.0-75'
# BUILDROOT='docker-registry.engineering.redhat.com/lucarval/rhel-buildroot:latest'

SOURCE_REGISTRY_URI=$_arg_source_registry
# SOURCE_REGISTRY_URI='http://registry.access.redhat.com'
# For building layered images:
# SOURCE_REGISTRY_URI='172.17.0.1:5000'

BUILDER_CMD='sudo docker exec -it osbsbox_koji-builder_1'

${BUILDER_CMD} sed --follow-symlinks -i \
    's;build_image = .*;build_image = '${BUILDROOT}';g' \
    /etc/osbs.conf
${BUILDER_CMD} sed --follow-symlinks -i 's;fedpkg;rhpkg;g' /etc/osbs.conf
${BUILDER_CMD} sed --follow-symlinks -i \
    's;source_registry_uri = .*;source_registry_uri = '${SOURCE_REGISTRY_URI}';g' \
    /etc/osbs.conf

${BUILDER_CMD} pip install --upgrade --force-reinstall --no-deps \
    "git+https://github.com/projectatomic/osbs-client.git@${OSBS_CLIENT_BRANCH}"

${BUILDER_CMD} pip install --upgrade --force-reinstall --no-deps \
    "git+https://github.com/release-engineering/koji-containerbuild@${KOJI_CONTAINERBUILD_BRANCH}"

${BUILDER_CMD} ln -fs \
    '/usr/lib/python2.7/site-packages/koji_containerbuild/plugins/builder_containerbuild.py' \
    '/usr/lib/koji-builder-plugins/builder_containerbuild.py'

# ${BUILDER_CMD} sed -i "s/koji_parent/koji_parent-disabled/g" /usr/share/osbs/prod_inner.json
# ${BUILDER_CMD} sed -i "s/koji_parent/koji_parent-disabled/g" /usr/share/osbs/orchestrator*

# docker cp ./orchestrator_inner\:4.json \
#     osbsbox_koji-builder_1:/usr/share/osbs/orchestrator_inner\:4.json

${BUILDER_CMD} systemctl restart kojid


CLIENT_CMD='sudo docker exec -it osbsbox_koji-client_1'

# sudo docker cp ./reactor-config-secret.yaml osbsbox_koji-client_1:/tmp/config.yaml
# sudo docker cp ./osbs.cert osbsbox_koji-client_1:/tmp/cert
${CLIENT_CMD} yum install -y python-pip
${CLIENT_CMD} pip install --upgrade --force-reinstall --no-deps \
    "git+https://github.com/release-engineering/koji-containerbuild@${KOJI_CONTAINERBUILD_BRANCH}"

# ${CLIENT_CMD} oc delete secret reactor-config-secret
# ${CLIENT_CMD} oc create secret generic reactor-config-secret --from-file=/tmp/config.yaml

# ${CLIENT_CMD} oc delete secret odcs-ssl-secret
# ${CLIENT_CMD} oc create secret generic odcs-ssl-secret --from-file=/tmp/cert

# ${CLIENT_CMD} koji add-tag osbs-test-odcs --arches=x86_64
# ${CLIENT_CMD} koji add-target candidate-odcs osbs-test-odcs dest


HUB_CMD='sudo docker exec -it osbsbox_koji-hub_1'

# ${HUB_CMD} koji-steal-build rhel-server-docker-7.4-120 \
#     --kojihub http://brewhub.engineering.redhat.com/brewhub \
#     --kojiroot http://brewweb.engineering.redhat.com/brewroot

# sudo docker pull rhel7:7.4-120
# sudo docker tag rhel7:7.4-120 172.17.0.1:5000/rhel7:7.4-120
# sudo docker push 172.17.0.1:5000/rhel7:7.4-120

# docker pull fedora:latest
# docker tag fedora:latest 172.17.0.1:5000/fedora:latest
# docker tag fedora:latest 172.17.0.1:5000/fedora:keepme
# docker push 172.17.0.1:5000/fedora:latest
# docker push 172.17.0.1:5000/fedora:keepme

echo 'Yay!'
# ] <-- needed because of Argbash