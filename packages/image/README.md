## Conventions for image plugins

The high-level commands used by the user to insert images are [img] and [timg]. Packages that generate images, like ttysnap, should emit these tags.

The packages in this directory take [img] and [timg] tags and emit [image] and [thumbnail] tags, which are the low-level tags consumed by the bbcode and HTML plugins.
