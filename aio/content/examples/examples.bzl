load("@build_bazel_rules_nodejs//:index.bzl", "npm_package_bin")
load("@aspect_bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")

# This map controls which examples are included and whether or not to generate
# a stackblitz live examples and zip archives. Keys are the example name, and values
# take the form:
#
#    {"stackblitz": boolean, "zip": boolean}
#
# Set "stackblitz" to True to generate live examples from any stackblitz config files
# found in the example. Set "zip" to True to generate archives for any stackblitz or
# zipper configuration file found in the example.
#

EXAMPLES = {
    "accessibility": {"stackblitz": True, "zip": True},
    "ajs-quick-reference": {"stackblitz": True, "zip": True},
    "angular-compiler-options": {"stackblitz": True, "zip": True},
    "animations": {"stackblitz": True, "zip": True},
    "architecture": {"stackblitz": True, "zip": True},
    "attribute-binding": {"stackblitz": True, "zip": True},
    "attribute-directives": {"stackblitz": True, "zip": True},
    "binding-syntax": {"stackblitz": True, "zip": True},
    "bootstrapping": {"stackblitz": True, "zip": True},
    "built-in-directives": {"stackblitz": True, "zip": True},
    "built-in-template-functions": {"stackblitz": True, "zip": True},
    "comparing-observables": {"stackblitz": False, "zip": False},
    "component-interaction": {"stackblitz": True, "zip": True},
    "component-overview": {"stackblitz": True, "zip": True},
    "component-styles": {"stackblitz": True, "zip": True},
    "content-projection": {"stackblitz": True, "zip": True},
    "dependency-injection": {"stackblitz": True, "zip": True},
    "dependency-injection-in-action": {"stackblitz": True, "zip": True},
    "deprecation-guide": {"stackblitz": True, "zip": True},
    "displaying-data": {"stackblitz": True, "zip": True},
    "docs-style-guide": {"stackblitz": True, "zip": True},
    "dynamic-component-loader": {"stackblitz": True, "zip": True},
    "dynamic-form": {"stackblitz": True, "zip": True},
    "elements": {"stackblitz": True, "zip": True},
    "event-binding": {"stackblitz": True, "zip": True},
    "feature-modules": {"stackblitz": True, "zip": True},
    "form-validation": {"stackblitz": True, "zip": True},
    "forms": {"stackblitz": True, "zip": True},
    "forms-overview": {"stackblitz": True, "zip": True},
    "getting-started": {"stackblitz": True, "zip": True},
    "getting-started-v0": {"stackblitz": True, "zip": True},
    "hierarchical-dependency-injection": {"stackblitz": True, "zip": True},
    "http": {"stackblitz": True, "zip": True},
    "i18n": {"stackblitz": True, "zip": True},
    "inputs-outputs": {"stackblitz": True, "zip": True},
    "interpolation": {"stackblitz": True, "zip": True},
    "lazy-loading-ngmodules": {"stackblitz": True, "zip": True},
    "lifecycle-hooks": {"stackblitz": True, "zip": True},
    "ngcontainer": {"stackblitz": True, "zip": True},
    "ngmodules": {"stackblitz": True, "zip": True},
    "observables": {"stackblitz": False, "zip": False},
    "observables-in-angular": {"stackblitz": False, "zip": False},
    "pipes": {"stackblitz": True, "zip": True},
    "practical-observable-usage": {"stackblitz": False, "zip": False},
    "property-binding": {"stackblitz": True, "zip": True},
    "providers": {"stackblitz": True, "zip": True},
    "providers-viewproviders": {"stackblitz": True, "zip": True},
    "reactive-forms": {"stackblitz": True, "zip": True},
    "resolution-modifiers": {"stackblitz": True, "zip": True},
    "router": {"stackblitz": True, "zip": True},
    "router-tutorial": {"stackblitz": True, "zip": True},
    "routing-with-urlmatcher": {"stackblitz": True, "zip": True},
    "rx-library": {"stackblitz": False, "zip": False},
    "schematics-for-libraries": {"stackblitz": False, "zip": True},
    "security": {"stackblitz": True, "zip": True},
    "service-worker-getting-started": {"stackblitz": False, "zip": False},
    "setup": {"stackblitz": False, "zip": False},
    "structural-directives": {"stackblitz": True, "zip": True},
    "styleguide": {"stackblitz": False, "zip": False},
    "template-expression-operators": {"stackblitz": True, "zip": True},
    "template-reference-variables": {"stackblitz": True, "zip": True},
    "template-syntax": {"stackblitz": True, "zip": True},
    "testing": {"stackblitz": True, "zip": True},
    "toh-pt0": {"stackblitz": True, "zip": True},
    "toh-pt1": {"stackblitz": True, "zip": True},
    "toh-pt2": {"stackblitz": True, "zip": True},
    "toh-pt3": {"stackblitz": True, "zip": True},
    "toh-pt4": {"stackblitz": True, "zip": True},
    "toh-pt5": {"stackblitz": True, "zip": True},
    "toh-pt6": {"stackblitz": True, "zip": True},
    "two-way-binding": {"stackblitz": True, "zip": True},
    "universal": {"stackblitz": False, "zip": True},
    "upgrade-lazy-load-ajs": {"stackblitz": False, "zip": True},
    "upgrade-module": {"stackblitz": False, "zip": False},
    "upgrade-phonecat-1-typescript": {"stackblitz": False, "zip": False},
    "upgrade-phonecat-2-hybrid": {"stackblitz": False, "zip": False},
    "upgrade-phonecat-3-final": {"stackblitz": False, "zip": False},
    "user-input": {"stackblitz": True, "zip": True},
    "view-encapsulation": {"stackblitz": True, "zip": True},
    "what-is-angular": {"stackblitz": True, "zip": True},
}

def docs_example(name):
    """Stamp targets for adding boilerplate to examples, creating live examples, and creating zips.

    Args:
        name: name of the example
    """
    if name not in EXAMPLES:
        fail("Cannot find example %s in the EXAMPLES map in aio/content/examples/examples.bzl. Did you forget to add an entry?" % name)

    native.filegroup(
        name = "files",
        srcs = native.glob(["**"], exclude = ["BUILD.bazel"]),
    )

    # Generate example boilerplate
    npm_package_bin(
        name = "boilerplate",
        args = ["add", native.package_name()],
        env = {
            "BAZEL_EXAMPLE_BOILERPLATE_OUTPUT_PATH": "$(@D)",
        },
        output_dir = True,
        tool = "//aio/tools/examples:example-boilerplate",
    )

    # Copy example files and boilerplate to the output tree
    copy_to_directory(
        name = name,
        # Prevent sorting so that boilerplate overwrites example sources
        # buildifier: do not sort
        srcs = [
            ":files",
            ":boilerplate",
        ],
        replace_prefixes = {
            "boilerplate": "",
        },
        allow_overwrites = True,
    )

    stackblitz_configs = native.glob(["*stackblitz.json"])

    if EXAMPLES[name]["stackblitz"] and len(stackblitz_configs) > 0:
        # Generate stackblitz live example(s)
        outs = [file_name.replace(".json", ".html") for file_name in stackblitz_configs]
        npm_package_bin(
            name = "stackblitz",
            args = [
                "$(execpath :%s)" % name,
                "$(RULEDIR)",
            ],
            data = [":%s" % name],
            outs = outs,
            tool = "//aio/tools/stackblitz-builder:generate-stackblitz",
        )

    zip_configs = stackblitz_configs + native.glob(["zipper.json"])

    if EXAMPLES[name]["zip"] and len(zip_configs) > 0:
        # Generate example zip(s)
        outs = [file_name.replace("stackblitz", name).replace("zipper", name).replace(".json", ".zip") for file_name in zip_configs]
        npm_package_bin(
            name = "example-zip",
            args = [
                "$(execpath :%s)" % name,
                "$(RULEDIR)",
            ],
            data = [":%s" % name],
            outs = outs,
            tool = "//aio/tools/example-zipper:generate-example-zip",
        )