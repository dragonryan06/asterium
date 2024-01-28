I figured I should make a thing explaining some details about generation because I'm going a little overboard with it

a lot of this is subject to change, for now, planets are fairly homogenous because they really are just decorations in the background
but i think it'd be cool at some point to add planetary surfaces and stuff and maybe then there could be distribution
and also then tectonics could play a role in that distribution

# Stars
A main-sequence star has a temperature and this determines its color, class, size, etc.
stars are, as of now, the simplest procedural feature in the game

# Planets
A terrestrial world is composed of rock.
rock is broken into three types:
- Igneous - volcanic rock formed from the freezing of liquid mineral soup (magma)
- Sedimentary - sandy rock formed from the deposition of sediment and rock fragments
- Metamorphic - shiny and dense rock formed from meteorite impacts, and other geologic activity to be added later

All terrestrial world rock starts as igneous rock, formed from magma with random minerals in it.
- The most important information to determining igneous rock type is its feldspar-index, a range from 0.0 to 1.0 (felsic to mafic), representing the ratio of Ca-feldspar to K-feldspar in its composition
- The secondary characteristic is the speed at which it cooled. Rapid cooling produces fine, small crystals, where as slow cooling produces larger crystals. In rare cases, extremely quick cooling can produce volcanic glass, aka obsidian.
