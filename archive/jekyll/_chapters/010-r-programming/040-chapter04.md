---
title:  Data Visualization
slug: chapter04
order: 045
published: true
abstract: >
    Readers will learn to create compelling visualizations using ggplot2, from basic plots to advanced customizations. This chapter emphasizes the power of visualization in exploring data and communicating results effectively, culminating in hands-on practice with real-world datasets.
---

## Introduction 
Data Visualization with ggplot2Data visualization is a cornerstone of the research lifecycle, serving as a critical tool for both exploration and communication. In the initial stages of a project, visualization allows for rapid exploratory data analysis (EDA), helping to uncover patterns, identify outliers, and formulate hypotheses. In the final stages, it becomes the primary medium for conveying complex findings to peers, stakeholders, and the public in a clear and impactful manner. Data visualization is not an afterthought but an integral and iterative part of the analytical process itself.Within the R ecosystem, the ggplot2 package stands as the preeminent tool for creating sophisticated and elegant graphics.1 As a core member of the tidyverse, ggplot2 is built upon a powerful and coherent philosophy known as the Grammar of Graphics. This conceptual framework allows you to construct a virtually limitless array of plots by combining a small set of fundamental components.3 Instead of being confined to a predefined set of chart types like "scatterplot" or "bar chart," you learn a system that empowers you to build precisely the graphic your data story requires.5This chapter provides a comprehensive guide to data visualization with ggplot2. We will begin by deconstructing the Grammar of Graphics to understand its theoretical underpinnings. From there, we will build foundational plot types for common analytical tasks. We will then master the art of customization, transforming basic plots into polished, publication-ready figures by controlling labels, colors, and themes. Finally, we will explore advanced techniques, including annotation, faceting, and density plots, and cover the essential last step of exporting your work for professional use.4.1 The Philosophy of ggplot2: The Grammar of GraphicsTo master ggplot2, one must first understand the philosophy that underpins it. The "gg" in ggplot2 stands for the Grammar of Graphics, a system that treats a plot not as a monolithic entity but as a composition of distinct layers.3 This approach is analogous to constructing a sentence: you begin with the essential elements—like a subject and a verb—and then add adjectives and clauses to add detail and nuance. By learning the components of this grammar, you gain the power to move beyond canned plot types and create visualizations uniquely tailored to your research questions.4A plot in ggplot2 is built up by adding layers. While these layers can become complex, every plot begins with three essential, non-negotiable components.5data: The dataset you wish to visualize. ggplot2 is fundamentally data-centric and requires your data to be in a data frame or a tibble. The package is designed to work most effectively with "tidy" data, where each row is an observation and each column is a variable.3aes() (Aesthetic Mappings): Aesthetics are the visual properties of the objects on your plot. These include properties you can see, such as x and y position, color, shape, size, and alpha (transparency). The aes() function's role is to create a mapping between variables in your data and these visual properties. It acts as a dictionary, telling ggplot2 how to translate your data into a visual representation.5 For example, aes(x = gdpPercap, y = lifeExp) maps the gdpPercap variable to the x-axis position and the lifeExp variable to the y-axis position.geoms (Geometric Objects): Geoms are the actual geometric shapes that represent the data on the plot. A geom_point() creates a scatter plot of points, a geom_line() creates a line chart, and a geom_bar() creates a bar chart. Adding a geom_*() function is what tells ggplot2 to actually draw something on the plot canvas.4These three components are brought together using a consistent syntax. The process begins with the ggplot() function, where you specify the data and the aesthetic mapping. This command creates a blank canvas with the axes defined, but no data is yet drawn.8 To render the plot, you must add a layer containing a geom using the + operator.The fundamental template is:ggplot(data = <DATA>, mapping = aes(<MAPPINGS>)) + <GEOM_FUNCTION>()For instance, using the penguins dataset from the palmerpenguins package, we can create a simple scatter plot.

R# Ensure the necessary packages are installed and loaded
# install.packages("tidyverse")
# install.packages("palmerpenguins")
library(tidyverse)
library(palmerpenguins)

# Create a basic ggplot object
ggplot(data = penguins, mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()
In this example, ggplot() initializes the plot with the penguins dataset and maps flipper length and body mass to the x and y axes. The + geom_point() layer then adds the points to create the scatter plot.6 The + operator is central to the ggplot2 workflow; it allows you to iteratively add more layers, such as additional geoms, custom scales, themes, or facets, building up a complex plot from simple, understandable pieces.3This layered grammar is more than just a syntax; it provides a powerful mental model for data visualization. Instead of searching for a specific function to make a particular chart, it encourages you to deconstruct your analytical goal: What data am I using? Which variables do I want to relate? How should I visually represent that relationship? This structured thinking (Data -> Aesthetics -> Geometry) is a robust problem-solving framework that fosters a deeper, more flexible approach to graphical creation.3While data, aes, and geoms are the essential starting points, the full Grammar of Graphics includes several other key components that provide finer control over the final plot. These components, summarized in Table 4.1, will be explored throughout this chapter.Table 4.1: Core Components of the Grammar of GraphicsComponentFunctionDescriptiondataThe datasetA data frame containing the variables to be plotted.aes()Aesthetic MappingsMaps variables from the data to visual properties of the plot (e.g., x/y position, color, size, shape).geomsGeometric ObjectsThe visual elements used to represent the data (e.g., geom_point(), geom_line(), geom_bar()).statsStatistical TransformationsSummarizes or transforms data before plotting (e.g., counting bins for a histogram, fitting a smooth line).scalesScale FunctionsControls the mapping from data values to aesthetic values (e.g., scale_color_brewer(), scale_x_continuous()). Manages axes and legends.facetsFacetingCreates subplots (small multiples) based on the levels of a categorical variable.coordsCoordinate SystemDefines the spatial mapping of the plot, typically Cartesian (coord_cartesian()) but can be others (e.g., polar).4.2 Foundational Plot Types: Visualizing Distributions and RelationshipsWith a theoretical understanding of the Grammar of Graphics, we can now apply it to create the foundational plots essential for any data analysis. Each geom corresponds to a specific way of visually encoding data, making it a deliberate choice that answers a particular analytical question. This section provides a practical toolbox for these common tasks, using the palmerpenguins and built-in mtcars and mpg datasets for all examples.4.2.1 Scatter Plots with geom_pointPurpose: To visualize the relationship between two continuous (numeric) variables. Each point on the plot represents a single observation.A scatter plot is created using geom_point(). To construct one, you map two continuous variables to the x and y aesthetics. For example, to explore the relationship between a penguin's flipper length and its body mass, we can use the following code 6:Rggplot(data = penguins, mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()
This simple plot already reveals a positive correlation. The power of the Grammar of Graphics becomes apparent when we add a third variable. By mapping a categorical variable, such as species, to another aesthetic like color, we can investigate whether the relationship holds across different groups. ggplot2 automatically handles the color assignments and generates a legend.3Rggplot(data = penguins, mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
  geom_point()
This layered approach allows us to quickly see that while the positive trend exists within each species, the species themselves form distinct clusters.4.2.2 Bar Plots with geom_bar and geom_colPurpose: To visualize the distribution of a categorical variable or to display pre-summarized values. A common point of confusion for new users is the difference between geom_bar() and geom_col().Using geom_bar() for Countsgeom_bar() is used when you want to plot the frequency or count of each category in a single categorical variable. It operates on an internal statistical transformation, stat="count", which automatically tabulates the data for you. Therefore, you only need to provide an x aesthetic.7For example, to see how many cars in the mtcars dataset have 4, 6, or 8 cylinders, we can use geom_bar(). It is good practice to wrap the categorical variable in factor() to ensure ggplot2 treats it as discrete.R# Note: The mtcars dataset is built into R
ggplot(data = mtcars, mapping = aes(x = factor(cyl))) +
  geom_bar()
Using geom_col() for Valuesgeom_col() (short for column) is used when your data is already summarized and you have a value for the height of each bar. In this case, you must provide both x and y aesthetics. This is equivalent to using geom_bar(stat = "identity").12For example, if we first calculate the mean horsepower (hp) for each cylinder category, we can then use geom_col() to plot these mean values.R# First, summarize the data
library(dplyr)
mtcars_summary <- mtcars %>%
  group_by(cyl) %>%
  summarise(mean_hp = mean(hp))

# Now, plot the pre-summarized values with geom_col()
ggplot(data = mtcars_summary, mapping = aes(x = factor(cyl), y = mean_hp)) +
  geom_col()
Choosing between geom_bar() and geom_col() depends entirely on the structure of your data: use geom_bar() for raw, uncounted categorical data and geom_col() for pre-summarized data with explicit bar heights.4.2.3 Histograms with geom_histogramPurpose: To visualize the distribution of a single continuous variable. A histogram works by dividing the variable's range into a series of intervals (bins) and plotting the number of observations that fall into each bin.A histogram is created with geom_histogram(). The most critical parameter for this geom is binwidth, which controls the width of the bins. The choice of binwidth can significantly alter the interpretation of the plot, revealing or obscuring features of the distribution. It is always recommended to experiment with several values.7Let's visualize the distribution of the mpg (miles per gallon) variable from the mtcars dataset.R# Histogram with a default binwidth
ggplot(data = mtcars, mapping = aes(x = mpg)) +
  geom_histogram()

# Histogram with a specified binwidth of 2
ggplot(data = mtcars, mapping = aes(x = mpg)) +
  geom_histogram(binwidth = 2)
The first plot uses a default number of bins (usually 30), while the second plot provides a more interpretable view by setting the binwidth to 2 miles per gallon.4.2.4 Box Plots with geom_boxplotPurpose: To visualize the distribution of a continuous variable as it varies across the levels of a categorical variable. A box plot provides a concise summary of a distribution's central tendency and spread.A box plot is created with geom_boxplot(). Typically, you map a categorical variable to the x aesthetic and a continuous variable to the y aesthetic. Each box plot displays the median (the central line), the interquartile range (IQR, the box itself, representing the middle 50% of the data), the whiskers (extending to 1.5 times the IQR from the box), and any outliers (plotted as individual points).7To compare the distribution of highway miles per gallon (hwy) across different car classes in the mpg dataset:R# The mpg dataset is part of ggplot2
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip() # Flip coordinates to make x-axis labels readable
This plot allows for quick comparisons, showing, for example, that 2-seater cars and subcompacts tend to have higher and more variable highway mileage than pickups and SUVs. The coord_flip() function is a useful trick for handling categorical variables with many or long labels.4.3 Enhancing Plots: Customization and CommunicationCreating a technically correct plot is only the first step. To be truly effective, a visualization must also communicate its message clearly and efficiently. This section focuses on moving beyond the default settings to produce polished, publication-quality graphics. Effective customization is not merely cosmetic; it is a functional part of the communication process, where each choice—from labels to colors to themes—has a direct impact on the plot's readability and the story it tells.4.3.1 Mapping vs. Setting: A Critical DistinctionA fundamental concept that often confuses new ggplot2 users is the distinction between mapping an aesthetic and setting it. This distinction hinges on whether the aesthetic's value depends on the data.11Mapping: When you want a visual property to vary based on a variable in your dataset, you place the aesthetic inside the aes() function. This creates a mapping from data values to visual values. ggplot2 will automatically create a scale (e.g., a color gradient or a set of discrete shapes) and a corresponding legend.Example (Correct Mapping): aes(color = species) maps the different values in the species column to different colors.Setting: When you want to apply a single, constant value to a visual property for all elements in a layer, you specify it outside the aes() function, as an argument to the geom function itself. This sets the aesthetic to a fixed value. No scale or legend is created.Example (Correct Setting): geom_point(color = "blue") sets the color of all points to blue.Let's illustrate with the mtcars dataset.R# Correct MAPPING: Color is mapped to the 'cyl' variable.
# A legend is created.
ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
  geom_point()

# Correct SETTING: The color of all points is set to "navy".
# No legend is created.
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point(color = "navy")

# INCORRECT: Tries to map the string "navy" to an aesthetic.
# This creates a legend with one item, "navy", and assigns it a default color.
ggplot(mtcars, aes(x = wt, y = mpg, color = "navy")) +
  geom_point()
Understanding this difference is crucial for gaining full control over your plot's appearance.4.3.2 Polishing for Publication: Titles, Labels, and Legends with labs()Clear and descriptive labels are non-negotiable for any graphic intended for an audience. ggplot2 provides the labs() function as a powerful and convenient way to control all labels from a single location.13 With labs(), you can set the main title, subtitle, caption (for sources or notes), x and y axis labels, and even the titles of legends.13To change a legend's title, you reference the aesthetic that the legend represents. For example, if your legend is for color, you would use labs(color = "New Legend Title").15R# Create a plot and store it in an object
p <- ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island))

# Add comprehensive labels using labs()
p + labs(
  title = "Penguin Body Mass vs. Flipper Length",
  subtitle = "Data from the Palmer Archipelago, Antarctica",
  x = "Flipper Length (mm)",
  y = "Body Mass (g)",
  color = "Penguin Species",
  shape = "Island of Origin",
  caption = "Source: palmerpenguins R package"
)
4.3.3 Controlling Scales: Customizing Axes and Color PalettesScales are the engines that control the mapping from data values to aesthetic values. They are also responsible for creating the guides that allow a reader to interpret that mapping: the axes and legends.4ggplot2 has a wide range of scale_*() functions to customize this process.Axis ScalesYou can finely control the appearance of your axes using functions like scale_x_continuous() and scale_y_continuous() for numeric axes, or scale_x_discrete() for categorical axes. Common arguments include 7:limits: Sets the lower and upper bounds of the axis.breaks: Controls the location of the tick marks.labels: Specifies the text to be displayed at each tick mark.R# Continuing with the penguin plot
p_labeled <- p + labs(
  title = "Penguin Body Mass vs. Flipper Length",
  x = "Flipper Length (mm)", y = "Body Mass (g)",
  color = "Penguin Species", shape = "Island of Origin"
)

# Customize the x and y axes
p_labeled +
  scale_x_continuous(
    limits = c(170, 240),
    breaks = seq(170, 240, by = 10)
  ) +
  scale_y_continuous(
    limits = c(2500, 6500),
    labels = function(x) paste(x / 1000, "kg") # Custom label formatting
  )
Color ScalesThe choice of color can dramatically affect a plot's readability and impact. ggplot2 provides different scale functions for different types of data.For discrete (categorical) variables: Use scale_color_brewer() or scale_fill_brewer() to apply professionally designed color palettes from the RColorBrewer package. Use scale_color_manual() or scale_fill_manual() to specify your own custom colors.16For continuous (numeric) variables: Use scale_color_gradient() to create a two-color gradient, or scale_color_viridis_c() to use the perceptually uniform and colorblind-friendly Viridis palettes.17R# Using a Brewer palette for discrete colors
p_labeled +
  scale_color_brewer(palette = "Set1")

# Using a Viridis palette for a continuous color mapping
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = bill_depth_mm), size = 3) +
  scale_color_viridis_c(option = "plasma") +
  labs(
    title = "Penguin Body Mass vs. Flipper Length",
    x = "Flipper Length (mm)", y = "Body Mass (g)",
    color = "Bill Depth (mm)"
  )
4.3.4 Theming for a Consistent LookThemes control the appearance of all non-data elements of your plot, such as titles, axis labels, gridlines, and the plot background.18 This allows you to create a consistent and professional look across all your visualizations.Complete ThemesThe easiest way to change the overall look of a plot is to apply a complete theme. ggplot2 comes with several built-in themes that serve as excellent starting points 19:theme_gray(): The signature ggplot2 default with a gray background.theme_bw(): A classic "black and white" theme with a white background and thin gridlines.theme_minimal(): A minimalist theme that removes background colors and most axis lines.theme_classic(): A traditional-looking theme with x and y axis lines but no gridlines.R# Apply the black-and-white theme
p_labeled + theme_bw()
Fine-Tuning with theme()For granular control, you can modify individual components using the theme() function. Theme elements are hierarchical; for example, modifying axis.title will affect both axis.title.x and axis.title.y. The most common elements to modify are text, rectangles, and lines, using the helper functions element_text(), element_rect(), and element_line() respectively.20Rp_labeled +
  theme_bw() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    legend.position = "bottom",
    axis.text = element_text(color = "grey30"),
    panel.grid.major = element_line(color = "grey90", linetype = "dashed")
  )
This code starts with theme_bw() and then makes specific modifications: it centers and bolds the title, moves the legend to the bottom, changes the color of the axis tick labels, and styles the major gridlines.4.4 Advanced Visualization TechniquesOnce you have mastered the fundamentals of creating and customizing plots, ggplot2 provides powerful tools for creating more complex and information-rich graphics. This section explores techniques for adding annotations, creating multi-panel plots with faceting, and visualizing data density in one and two dimensions.4.4.1 Telling Stories with AnnotationsAnnotations add layers of context or highlight specific features directly on the plot, turning a simple graphic into a compelling narrative. ggplot2 offers several tools for this purpose.14annotate(): This function is ideal for adding a single, static geometric object whose properties are not mapped to data. You specify the geom you want to add (e.g., "text", "rect", "segment") and its aesthetic properties as arguments.21 For example, you can highlight a specific time period with a shaded rectangle or add a descriptive label at a fixed coordinate.geom_text() and geom_label(): These geoms are used when you want to add text labels whose positions are derived from the data (i.e., mapped via aes(x =..., y =...)). geom_label() is particularly useful as it draws a rectangle behind the text, making it more legible against a busy background.14geom_vline() and geom_hline(): These functions add vertical and horizontal reference lines that span the entire plot, useful for marking thresholds or mean values.21A common challenge with text annotations is label overlap. While geom_text() has a check_overlap = TRUE argument, a more robust solution is the ggrepel package. Its geom_text_repel() function intelligently positions labels to avoid overlapping each other and the data points, an essential tool for creating clean, readable plots.23R# Using annotate() to highlight a region and add a label
highlight_df <- data.frame(
  xmin = 200, xmax = 220,
  ymin = 5000, ymax = 6500,
  label = "Large Chinstrap & Gentoo Penguins"
)

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species)) +
  annotate(
    "rect",
    xmin = highlight_df$xmin, xmax = highlight_df$xmax,
    ymin = highlight_df$ymin, ymax = highlight_df$ymax,
    alpha = 0.1, fill = "blue"
  ) +
  annotate(
    "text",
    x = 180, y = 6000,
    label = highlight_df$label,
    hjust = 0
  ) +
  theme_bw()
4.4.2 Creating Small Multiples with FacetingFaceting is the Grammar of Graphics' answer to conditional plotting. It splits a single plot into a matrix of subplots (often called "small multiples"), with each subplot displaying a different subset of the data. This is an exceptionally powerful technique for understanding how relationships between variables change across different groups or conditions.9 Overloading a single plot with too many aesthetics (color, shape, size, etc.) can quickly become perceptually overwhelming; faceting provides a cleaner, more scalable alternative for exploring multivariate data.3ggplot2 provides two main faceting functions, facet_wrap() and facet_grid().facet_wrap()facet_wrap() is best suited for faceting by a single categorical variable, especially one with many levels. It arranges the panels in a 2D layout, "wrapping" the sequence of plots to fit efficiently in the available space. The layout can be controlled with the nrow and ncol arguments.26 The syntax uses a tilde (~) followed by the variable name.Rggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_wrap(~ class, nrow = 2) + # Facet by car class, arrange in 2 rows
  theme_bw()
facet_grid()facet_grid() creates a rigid 2D grid of panels defined by two variables, one for the rows and one for the columns. The syntax is rows_variable ~ cols_variable. This function is useful when you want to see every combination of two variables, even if some combinations result in empty panels.27Rggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_grid(drv ~ cyl) + # Facet by drive type (rows) and cylinders (columns)
  theme_bw()
Controlling Facet ScalesBy default, all panels in a faceted plot share the same axis scales (scales = "fixed"). This is ideal for comparing absolute values across panels. However, sometimes the data ranges vary so much between panels that this default makes it hard to see patterns within individual panels. The scales argument gives you control over this behavior 26:scales = "free": Both x and y axes scales are independent for each panel.scales = "free_x": X-axis scales are independent; y-axis is fixed.scales = "free_y": Y-axis scales are independent; x-axis is fixed.Choosing the right scale setting is a crucial decision based on whether the primary goal is to compare across panels (fixed scales) or to see the detail within each panel (free scales).Table 4.2: Comparison of facet_wrap() and facet_grid()Featurefacet_wrap()facet_grid()Primary Use CaseFaceting by one or more variables, wrapped into a 2D layout.Faceting by one or two variables in a rigid grid structure.Syntax~ var1 + var2var_rows ~ var_colsLayout ControlFlexible, controlled by nrow and ncol.Rigid, determined by the number of levels in the faceting variables.Handling of Empty CombinationsDoes not show panels for combinations of levels not present in the data.Shows all possible panels, including empty ones if combinations are missing.Best ForA single categorical variable with many levels.Two categorical variables where you want to see all combinations in a matrix.4.4.3 Visualizing Density: 1D and 2D PlotsWhile histograms are excellent for understanding distributions, smoothed density plots can provide a clearer view of the underlying shape. This concept extends from one dimension to two, where heatmaps can reveal density in crowded scatter plots.1D Density with geom_densityA 1D density plot, created with geom_density(), is a smoothed version of a histogram. It estimates the probability density function of a continuous variable, making it easier to see the distribution's shape without being distracted by the choice of binwidth.30 It is often useful to overlay a semi-transparent density plot on a histogram to get the benefits of both representations.31Rggplot(penguins, aes(x = body_mass_g)) +
  # Plot histogram with y-axis as density instead of count
  geom_histogram(aes(y = after_stat(density)), fill = "lightblue", color = "white", binwidth = 250) +
  # Overlay a density line
  geom_density(color = "darkblue", linewidth = 1) +
  theme_minimal()
2D Density (Heatmaps) with geom_tileWhen a scatter plot suffers from overplotting (too many points stacked on top of each other), it can be difficult to discern the true density of the data. A heatmap is an excellent solution. The primary geom for creating heatmaps in ggplot2 is geom_tile().17A critical prerequisite for using geom_tile() is that the data must be in a "long" or "tidy" format. This means you need a data frame with at least three columns: one for the x-axis position, one for the y-axis position, and one for the value that will be mapped to the fill color.33 Data, such as a correlation matrix, is often in a "wide" format and must be reshaped first, typically using the pivot_longer() function from the tidyr package.Let's create a correlation matrix for the numeric variables in mtcars and visualize it as a heatmap.R# 1. Select only numeric columns and compute the correlation matrix
cor_matrix <- mtcars %>%
  select(where(is.numeric)) %>%
  cor()

# 2. Reshape the matrix from wide to long format
cor_df <- as.data.frame(cor_matrix) %>%
  rownames_to_column(var = "Var1") %>%
  pivot_longer(
    cols = -Var1,
    names_to = "Var2",
    values_to = "correlation"
  )

# 3. Create the heatmap with geom_tile()
ggplot(cor_df, aes(x = Var1, y = Var2, fill = correlation)) +
  geom_tile(color = "white") + # Add white lines between tiles
  scale_fill_gradient2( # Use a diverging color palette
    low = "blue", high = "red", mid = "white",
    midpoint = 0, limit = c(-1, 1),
    name = "Correlation"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) + # Rotate x-axis labels
  coord_fixed() # Ensure tiles are square
This process—calculate, reshape, plot—is a standard workflow for visualizing matrix data with ggplot2. Other geoms like geom_bin2d() and geom_hex() provide alternative ways to visualize 2D density by binning points into rectangles or hexagons, respectively.344.5 From Screen to Paper: Exporting Publication-Quality GraphicsThe final step in any visualization workflow is to save the plot for use in a publication, presentation, or report. The technical choices made at this stage directly impact the professional quality of the output. A beautiful plot can be ruined by poor export settings. ggplot2 provides the ggsave() function as a simple and reproducible way to ensure the visual quality created in R is preserved in the final document.35The ggsave() Functionggsave() is the canonical function for saving ggplot objects. By default, it saves the last plot that was displayed in your R session. Its most powerful feature is that it can infer the desired file format from the extension you provide in the filename (e.g., .pdf, .png, .svg).36The function's key arguments give you precise control over the final output.36filename: The name and path for the output file. The extension determines the file type.plot: The specific plot object to save (e.g., plot = my_plot). Defaults to the last plot.width, height, units: These control the physical dimensions of the saved image (e.g., units = "in" or "cm"). Specifying these is crucial for consistency in documents and presentations.35dpi: "Dots per inch," which controls the resolution for raster formats like PNG and JPEG. A common standard for print is 300 dpi, while 600 dpi provides higher resolution. For web, 72 dpi is often sufficient.36R# First, create and polish a plot
final_plot <- ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
  geom_point(alpha = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Body Mass vs. Flipper Length in Palmer Penguins",
    x = "Flipper Length (mm)",
    y = "Body Mass (g)",
    color = "Species"
  ) +
  theme_bw()

# Now, save the plot using ggsave()
ggsave(
  filename = "penguin_plot.png",
  plot = final_plot,
  width = 8,
  height = 6,
  units = "in",
  dpi = 300
)
Best Practices for PublicationVector vs. Raster FormatsUnderstanding the difference between vector and raster graphics is critical for professional output.Vector Graphics (.pdf, .svg): These formats store images as a set of mathematical instructions for drawing lines and shapes. Their key advantage is infinite scalability; they can be resized to any dimension without losing quality or becoming pixelated. For most academic publications (which often use LaTeX or require PDF submissions), vector formats are strongly preferred.35Raster Graphics (.png, .jpg, .tiff): These formats store images as a grid of pixels. They are ideal for complex images like photographs but will lose quality if scaled up beyond their original resolution. Use high-resolution PNGs (dpi = 300 or higher) for plots with a very high density of points (where vector files can become very large and slow to render) or for web use.39ReproducibilityUsing ggsave() in your R script is a cornerstone of reproducible research. While it is possible to export a plot manually from the RStudio "Plots" pane, this action is not recorded in your code. Saving programmatically with ggsave() ensures that anyone (including your future self) can regenerate the exact same figure with the exact same dimensions and resolution simply by running the script.35Table 4.3: Key Arguments for ggsave()ArgumentDescriptionExamplefilenameThe name of the output file. The extension determines the file type."my_plot.pdf", "figure1.png"plotThe plot object to save. Defaults to the last plot displayed.plot = my_scatter_plotwidthThe width of the saved plot.width = 7heightThe height of the saved plot.height = 5unitsThe units for width and height.units = "in" (default), "cm", "mm"dpiThe resolution in dots per inch (for raster formats like PNG).dpi = 300 (print), dpi = 600 (high-res)bgThe background color. Defaults to the plot's theme background.bg = "white"



---------------------------------------------------------------------------------------------------




# **Chapter 4: Data Visualization with ggplot2**

Data visualization is a cornerstone of the research lifecycle, serving as a critical tool for both exploration and communication. In the initial stages of a project, visualization allows for rapid exploratory data analysis (EDA), helping to uncover patterns, identify outliers, and formulate hypotheses. In the final stages, it becomes the primary medium for conveying complex findings to peers, stakeholders, and the public in a clear and impactful manner. Data visualization is not an afterthought but an integral and iterative part of the analytical process itself.

Within the R ecosystem, the ggplot2 package stands as the preeminent tool for creating sophisticated and elegant graphics.1 As a core member of the

tidyverse, ggplot2 is built upon a powerful and coherent philosophy known as the **Grammar of Graphics**. This conceptual framework allows you to construct a virtually limitless array of plots by combining a small set of fundamental components.3 Instead of being confined to a predefined set of chart types like "scatterplot" or "bar chart," you learn a system that empowers you to build precisely the graphic your data story requires.5

This chapter provides a comprehensive guide to data visualization with ggplot2. We will begin by deconstructing the Grammar of Graphics to understand its theoretical underpinnings. From there, we will build foundational plot types for common analytical tasks. We will then master the art of customization, transforming basic plots into polished, publication-ready figures by controlling labels, colors, and themes. Finally, we will explore advanced techniques, including annotation, faceting, and density plots, and cover the essential last step of exporting your work for professional use.

## **4.1 The Philosophy of ggplot2: The Grammar of Graphics**

To master ggplot2, one must first understand the philosophy that underpins it. The "gg" in ggplot2 stands for the Grammar of Graphics, a system that treats a plot not as a monolithic entity but as a composition of distinct layers.3 This approach is analogous to constructing a sentence: you begin with the essential elements—like a subject and a verb—and then add adjectives and clauses to add detail and nuance. By learning the components of this grammar, you gain the power to move beyond canned plot types and create visualizations uniquely tailored to your research questions.4

A plot in ggplot2 is built up by adding layers. While these layers can become complex, every plot begins with three essential, non-negotiable components.5

1. **data**: The dataset you wish to visualize. ggplot2 is fundamentally data-centric and requires your data to be in a data frame or a tibble. The package is designed to work most effectively with "tidy" data, where each row is an observation and each column is a variable.3  
2. **aes() (Aesthetic Mappings)**: Aesthetics are the visual properties of the objects on your plot. These include properties you can see, such as x and y position, color, shape, size, and alpha (transparency). The aes() function's role is to create a *mapping* between variables in your data and these visual properties. It acts as a dictionary, telling ggplot2 how to translate your data into a visual representation.5 For example,  
   aes(x \= gdpPercap, y \= lifeExp) maps the gdpPercap variable to the x-axis position and the lifeExp variable to the y-axis position.  
3. **geoms (Geometric Objects)**: Geoms are the actual geometric shapes that represent the data on the plot. A geom\_point() creates a scatter plot of points, a geom\_line() creates a line chart, and a geom\_bar() creates a bar chart. Adding a geom\_\*() function is what tells ggplot2 to actually draw something on the plot canvas.4

These three components are brought together using a consistent syntax. The process begins with the ggplot() function, where you specify the data and the aesthetic mapping. This command creates a blank canvas with the axes defined, but no data is yet drawn.8 To render the plot, you must add a layer containing a

geom using the \+ operator.

The fundamental template is:  
ggplot(data \= \<DATA\>, mapping \= aes(\<MAPPINGS\>)) \+ \<GEOM\_FUNCTION\>()  
For instance, using the penguins dataset from the palmerpenguins package, we can create a simple scatter plot.

R

\# Ensure the necessary packages are installed and loaded  
\# install.packages("tidyverse")  
\# install.packages("palmerpenguins")  
library(tidyverse)  
library(palmerpenguins)

\# Create a basic ggplot object  
ggplot(data \= penguins, mapping \= aes(x \= flipper\_length\_mm, y \= body\_mass\_g)) \+  
  geom\_point()

In this example, ggplot() initializes the plot with the penguins dataset and maps flipper length and body mass to the x and y axes. The \+ geom\_point() layer then adds the points to create the scatter plot.6 The

\+ operator is central to the ggplot2 workflow; it allows you to iteratively add more layers, such as additional geoms, custom scales, themes, or facets, building up a complex plot from simple, understandable pieces.3

This layered grammar is more than just a syntax; it provides a powerful mental model for data visualization. Instead of searching for a specific function to make a particular chart, it encourages you to deconstruct your analytical goal: What data am I using? Which variables do I want to relate? How should I visually represent that relationship? This structured thinking (Data \-\> Aesthetics \-\> Geometry) is a robust problem-solving framework that fosters a deeper, more flexible approach to graphical creation.3

While data, aes, and geoms are the essential starting points, the full Grammar of Graphics includes several other key components that provide finer control over the final plot. These components, summarized in Table 4.1, will be explored throughout this chapter.

**Table 4.1: Core Components of the Grammar of Graphics**

| Component | Function | Description |
| :---- | :---- | :---- |
| data | The dataset | A data frame containing the variables to be plotted. |
| aes() | Aesthetic Mappings | Maps variables from the data to visual properties of the plot (e.g., x/y position, color, size, shape). |
| geoms | Geometric Objects | The visual elements used to represent the data (e.g., geom\_point(), geom\_line(), geom\_bar()). |
| stats | Statistical Transformations | Summarizes or transforms data before plotting (e.g., counting bins for a histogram, fitting a smooth line). |
| scales | Scale Functions | Controls the mapping from data values to aesthetic values (e.g., scale\_color\_brewer(), scale\_x\_continuous()). Manages axes and legends. |
| facets | Faceting | Creates subplots (small multiples) based on the levels of a categorical variable. |
| coords | Coordinate System | Defines the spatial mapping of the plot, typically Cartesian (coord\_cartesian()) but can be others (e.g., polar). |

## **4.2 Foundational Plot Types: Visualizing Distributions and Relationships**

With a theoretical understanding of the Grammar of Graphics, we can now apply it to create the foundational plots essential for any data analysis. Each geom corresponds to a specific way of visually encoding data, making it a deliberate choice that answers a particular analytical question. This section provides a practical toolbox for these common tasks, using the palmerpenguins and built-in mtcars and mpg datasets for all examples.

### **4.2.1 Scatter Plots with geom\_point**

**Purpose:** To visualize the relationship between two continuous (numeric) variables. Each point on the plot represents a single observation.

A scatter plot is created using geom\_point(). To construct one, you map two continuous variables to the x and y aesthetics. For example, to explore the relationship between a penguin's flipper length and its body mass, we can use the following code 6:

R

ggplot(data \= penguins, mapping \= aes(x \= flipper\_length\_mm, y \= body\_mass\_g)) \+  
  geom\_point()

This simple plot already reveals a positive correlation. The power of the Grammar of Graphics becomes apparent when we add a third variable. By mapping a categorical variable, such as species, to another aesthetic like color, we can investigate whether the relationship holds across different groups. ggplot2 automatically handles the color assignments and generates a legend.3

R

ggplot(data \= penguins, mapping \= aes(x \= flipper\_length\_mm, y \= body\_mass\_g, color \= species)) \+  
  geom\_point()

This layered approach allows us to quickly see that while the positive trend exists within each species, the species themselves form distinct clusters.

### **4.2.2 Bar Plots with geom\_bar and geom\_col**

**Purpose:** To visualize the distribution of a categorical variable or to display pre-summarized values. A common point of confusion for new users is the difference between geom\_bar() and geom\_col().

#### **Using geom\_bar() for Counts**

geom\_bar() is used when you want to plot the frequency or count of each category in a single categorical variable. It operates on an internal statistical transformation, stat="count", which automatically tabulates the data for you. Therefore, you only need to provide an x aesthetic.7

For example, to see how many cars in the mtcars dataset have 4, 6, or 8 cylinders, we can use geom\_bar(). It is good practice to wrap the categorical variable in factor() to ensure ggplot2 treats it as discrete.

R

\# Note: The mtcars dataset is built into R  
ggplot(data \= mtcars, mapping \= aes(x \= factor(cyl))) \+  
  geom\_bar()

#### **Using geom\_col() for Values**

geom\_col() (short for column) is used when your data is already summarized and you have a value for the height of each bar. In this case, you must provide both x and y aesthetics. This is equivalent to using geom\_bar(stat \= "identity").12

For example, if we first calculate the mean horsepower (hp) for each cylinder category, we can then use geom\_col() to plot these mean values.

R

\# First, summarize the data  
library(dplyr)  
mtcars\_summary \<- mtcars %\>%  
  group\_by(cyl) %\>%  
  summarise(mean\_hp \= mean(hp))

\# Now, plot the pre-summarized values with geom\_col()  
ggplot(data \= mtcars\_summary, mapping \= aes(x \= factor(cyl), y \= mean\_hp)) \+  
  geom\_col()

Choosing between geom\_bar() and geom\_col() depends entirely on the structure of your data: use geom\_bar() for raw, uncounted categorical data and geom\_col() for pre-summarized data with explicit bar heights.

### **4.2.3 Histograms with geom\_histogram**

**Purpose:** To visualize the distribution of a single continuous variable. A histogram works by dividing the variable's range into a series of intervals (bins) and plotting the number of observations that fall into each bin.

A histogram is created with geom\_histogram(). The most critical parameter for this geom is binwidth, which controls the width of the bins. The choice of binwidth can significantly alter the interpretation of the plot, revealing or obscuring features of the distribution. It is always recommended to experiment with several values.7

Let's visualize the distribution of the mpg (miles per gallon) variable from the mtcars dataset.

R

\# Histogram with a default binwidth  
ggplot(data \= mtcars, mapping \= aes(x \= mpg)) \+  
  geom\_histogram()

\# Histogram with a specified binwidth of 2  
ggplot(data \= mtcars, mapping \= aes(x \= mpg)) \+  
  geom\_histogram(binwidth \= 2)

The first plot uses a default number of bins (usually 30), while the second plot provides a more interpretable view by setting the binwidth to 2 miles per gallon.

### **4.2.4 Box Plots with geom\_boxplot**

**Purpose:** To visualize the distribution of a continuous variable as it varies across the levels of a categorical variable. A box plot provides a concise summary of a distribution's central tendency and spread.

A box plot is created with geom\_boxplot(). Typically, you map a categorical variable to the x aesthetic and a continuous variable to the y aesthetic. Each box plot displays the median (the central line), the interquartile range (IQR, the box itself, representing the middle 50% of the data), the whiskers (extending to 1.5 times the IQR from the box), and any outliers (plotted as individual points).7

To compare the distribution of highway miles per gallon (hwy) across different car classes in the mpg dataset:

R

\# The mpg dataset is part of ggplot2  
ggplot(data \= mpg, mapping \= aes(x \= class, y \= hwy)) \+  
  geom\_boxplot() \+  
  coord\_flip() \# Flip coordinates to make x-axis labels readable

This plot allows for quick comparisons, showing, for example, that 2-seater cars and subcompacts tend to have higher and more variable highway mileage than pickups and SUVs. The coord\_flip() function is a useful trick for handling categorical variables with many or long labels.

## **4.3 Enhancing Plots: Customization and Communication**

Creating a technically correct plot is only the first step. To be truly effective, a visualization must also communicate its message clearly and efficiently. This section focuses on moving beyond the default settings to produce polished, publication-quality graphics. Effective customization is not merely cosmetic; it is a functional part of the communication process, where each choice—from labels to colors to themes—has a direct impact on the plot's readability and the story it tells.

### **4.3.1 Mapping vs. Setting: A Critical Distinction**

A fundamental concept that often confuses new ggplot2 users is the distinction between *mapping* an aesthetic and *setting* it. This distinction hinges on whether the aesthetic's value depends on the data.11

* **Mapping:** When you want a visual property to vary based on a variable in your dataset, you place the aesthetic inside the aes() function. This creates a *mapping* from data values to visual values. ggplot2 will automatically create a scale (e.g., a color gradient or a set of discrete shapes) and a corresponding legend.  
  * **Example (Correct Mapping):** aes(color \= species) maps the different values in the species column to different colors.  
* **Setting:** When you want to apply a single, constant value to a visual property for all elements in a layer, you specify it *outside* the aes() function, as an argument to the geom function itself. This *sets* the aesthetic to a fixed value. No scale or legend is created.  
  * **Example (Correct Setting):** geom\_point(color \= "blue") sets the color of *all* points to blue.

Let's illustrate with the mtcars dataset.

R

\# Correct MAPPING: Color is mapped to the 'cyl' variable.  
\# A legend is created.  
ggplot(mtcars, aes(x \= wt, y \= mpg, color \= factor(cyl))) \+  
  geom\_point()

\# Correct SETTING: The color of all points is set to "navy".  
\# No legend is created.  
ggplot(mtcars, aes(x \= wt, y \= mpg)) \+  
  geom\_point(color \= "navy")

\# INCORRECT: Tries to map the string "navy" to an aesthetic.  
\# This creates a legend with one item, "navy", and assigns it a default color.  
ggplot(mtcars, aes(x \= wt, y \= mpg, color \= "navy")) \+  
  geom\_point()

Understanding this difference is crucial for gaining full control over your plot's appearance.

### **4.3.2 Polishing for Publication: Titles, Labels, and Legends with labs()**

Clear and descriptive labels are non-negotiable for any graphic intended for an audience. ggplot2 provides the labs() function as a powerful and convenient way to control all labels from a single location.13 With

labs(), you can set the main title, subtitle, caption (for sources or notes), x and y axis labels, and even the titles of legends.13

To change a legend's title, you reference the aesthetic that the legend represents. For example, if your legend is for color, you would use labs(color \= "New Legend Title").15

R

\# Create a plot and store it in an object  
p \<- ggplot(penguins, aes(x \= flipper\_length\_mm, y \= body\_mass\_g)) \+  
  geom\_point(aes(color \= species, shape \= island))

\# Add comprehensive labels using labs()  
p \+ labs(  
  title \= "Penguin Body Mass vs. Flipper Length",  
  subtitle \= "Data from the Palmer Archipelago, Antarctica",  
  x \= "Flipper Length (mm)",  
  y \= "Body Mass (g)",  
  color \= "Penguin Species",  
  shape \= "Island of Origin",  
  caption \= "Source: palmerpenguins R package"  
)

### **4.3.3 Controlling Scales: Customizing Axes and Color Palettes**

Scales are the engines that control the mapping from data values to aesthetic values. They are also responsible for creating the guides that allow a reader to interpret that mapping: the axes and legends.4

ggplot2 has a wide range of scale\_\*() functions to customize this process.

#### **Axis Scales**

You can finely control the appearance of your axes using functions like scale\_x\_continuous() and scale\_y\_continuous() for numeric axes, or scale\_x\_discrete() for categorical axes. Common arguments include 7:

* limits: Sets the lower and upper bounds of the axis.  
* breaks: Controls the location of the tick marks.  
* labels: Specifies the text to be displayed at each tick mark.

R

\# Continuing with the penguin plot  
p\_labeled \<- p \+ labs(  
  title \= "Penguin Body Mass vs. Flipper Length",  
  x \= "Flipper Length (mm)", y \= "Body Mass (g)",  
  color \= "Penguin Species", shape \= "Island of Origin"  
)

\# Customize the x and y axes  
p\_labeled \+  
  scale\_x\_continuous(  
    limits \= c(170, 240),  
    breaks \= seq(170, 240, by \= 10)  
  ) \+  
  scale\_y\_continuous(  
    limits \= c(2500, 6500),  
    labels \= function(x) paste(x / 1000, "kg") \# Custom label formatting  
  )

#### **Color Scales**

The choice of color can dramatically affect a plot's readability and impact. ggplot2 provides different scale functions for different types of data.

* **For discrete (categorical) variables:** Use scale\_color\_brewer() or scale\_fill\_brewer() to apply professionally designed color palettes from the RColorBrewer package. Use scale\_color\_manual() or scale\_fill\_manual() to specify your own custom colors.16  
* **For continuous (numeric) variables:** Use scale\_color\_gradient() to create a two-color gradient, or scale\_color\_viridis\_c() to use the perceptually uniform and colorblind-friendly Viridis palettes.17

R

\# Using a Brewer palette for discrete colors  
p\_labeled \+  
  scale\_color\_brewer(palette \= "Set1")

\# Using a Viridis palette for a continuous color mapping  
ggplot(penguins, aes(x \= flipper\_length\_mm, y \= body\_mass\_g)) \+  
  geom\_point(aes(color \= bill\_depth\_mm), size \= 3) \+  
  scale\_color\_viridis\_c(option \= "plasma") \+  
  labs(  
    title \= "Penguin Body Mass vs. Flipper Length",  
    x \= "Flipper Length (mm)", y \= "Body Mass (g)",  
    color \= "Bill Depth (mm)"  
  )

### **4.3.4 Theming for a Consistent Look**

Themes control the appearance of all non-data elements of your plot, such as titles, axis labels, gridlines, and the plot background.18 This allows you to create a consistent and professional look across all your visualizations.

#### **Complete Themes**

The easiest way to change the overall look of a plot is to apply a complete theme. ggplot2 comes with several built-in themes that serve as excellent starting points 19:

* theme\_gray(): The signature ggplot2 default with a gray background.  
* theme\_bw(): A classic "black and white" theme with a white background and thin gridlines.  
* theme\_minimal(): A minimalist theme that removes background colors and most axis lines.  
* theme\_classic(): A traditional-looking theme with x and y axis lines but no gridlines.

R

\# Apply the black-and-white theme  
p\_labeled \+ theme\_bw()

#### **Fine-Tuning with theme()**

For granular control, you can modify individual components using the theme() function. Theme elements are hierarchical; for example, modifying axis.title will affect both axis.title.x and axis.title.y. The most common elements to modify are text, rectangles, and lines, using the helper functions element\_text(), element\_rect(), and element\_line() respectively.20

R

p\_labeled \+  
  theme\_bw() \+  
  theme(  
    plot.title \= element\_text(size \= 16, face \= "bold", hjust \= 0.5),  
    legend.position \= "bottom",  
    axis.text \= element\_text(color \= "grey30"),  
    panel.grid.major \= element\_line(color \= "grey90", linetype \= "dashed")  
  )

This code starts with theme\_bw() and then makes specific modifications: it centers and bolds the title, moves the legend to the bottom, changes the color of the axis tick labels, and styles the major gridlines.

## **4.4 Advanced Visualization Techniques**

Once you have mastered the fundamentals of creating and customizing plots, ggplot2 provides powerful tools for creating more complex and information-rich graphics. This section explores techniques for adding annotations, creating multi-panel plots with faceting, and visualizing data density in one and two dimensions.

### **4.4.1 Telling Stories with Annotations**

Annotations add layers of context or highlight specific features directly on the plot, turning a simple graphic into a compelling narrative. ggplot2 offers several tools for this purpose.14

* **annotate()**: This function is ideal for adding a single, static geometric object whose properties are not mapped to data. You specify the geom you want to add (e.g., "text", "rect", "segment") and its aesthetic properties as arguments.21 For example, you can highlight a specific time period with a shaded rectangle or add a descriptive label at a fixed coordinate.  
* **geom\_text() and geom\_label()**: These geoms are used when you want to add text labels whose positions are derived from the data (i.e., mapped via aes(x \=..., y \=...)). geom\_label() is particularly useful as it draws a rectangle behind the text, making it more legible against a busy background.14  
* **geom\_vline() and geom\_hline()**: These functions add vertical and horizontal reference lines that span the entire plot, useful for marking thresholds or mean values.21

A common challenge with text annotations is label overlap. While geom\_text() has a check\_overlap \= TRUE argument, a more robust solution is the ggrepel package. Its geom\_text\_repel() function intelligently positions labels to avoid overlapping each other and the data points, an essential tool for creating clean, readable plots.23

R

\# Using annotate() to highlight a region and add a label  
highlight\_df \<- data.frame(  
  xmin \= 200, xmax \= 220,  
  ymin \= 5000, ymax \= 6500,  
  label \= "Large Chinstrap & Gentoo Penguins"  
)

ggplot(penguins, aes(x \= flipper\_length\_mm, y \= body\_mass\_g)) \+  
  geom\_point(aes(color \= species)) \+  
  annotate(  
    "rect",  
    xmin \= highlight\_df$xmin, xmax \= highlight\_df$xmax,  
    ymin \= highlight\_df$ymin, ymax \= highlight\_df$ymax,  
    alpha \= 0.1, fill \= "blue"  
  ) \+  
  annotate(  
    "text",  
    x \= 180, y \= 6000,  
    label \= highlight\_df$label,  
    hjust \= 0  
  ) \+  
  theme\_bw()

### **4.4.2 Creating Small Multiples with Faceting**

Faceting is the Grammar of Graphics' answer to conditional plotting. It splits a single plot into a matrix of subplots (often called "small multiples"), with each subplot displaying a different subset of the data. This is an exceptionally powerful technique for understanding how relationships between variables change across different groups or conditions.9 Overloading a single plot with too many aesthetics (color, shape, size, etc.) can quickly become perceptually overwhelming; faceting provides a cleaner, more scalable alternative for exploring multivariate data.3

ggplot2 provides two main faceting functions, facet\_wrap() and facet\_grid().

#### **facet\_wrap()**

facet\_wrap() is best suited for faceting by a single categorical variable, especially one with many levels. It arranges the panels in a 2D layout, "wrapping" the sequence of plots to fit efficiently in the available space. The layout can be controlled with the nrow and ncol arguments.26 The syntax uses a tilde (

\~) followed by the variable name.

R

ggplot(mpg, aes(x \= displ, y \= hwy)) \+  
  geom\_point() \+  
  facet\_wrap(\~ class, nrow \= 2) \+ \# Facet by car class, arrange in 2 rows  
  theme\_bw()

#### **facet\_grid()**

facet\_grid() creates a rigid 2D grid of panels defined by two variables, one for the rows and one for the columns. The syntax is rows\_variable \~ cols\_variable. This function is useful when you want to see every combination of two variables, even if some combinations result in empty panels.27

R

ggplot(mpg, aes(x \= displ, y \= hwy)) \+  
  geom\_point() \+  
  facet\_grid(drv \~ cyl) \+ \# Facet by drive type (rows) and cylinders (columns)  
  theme\_bw()

#### **Controlling Facet Scales**

By default, all panels in a faceted plot share the same axis scales (scales \= "fixed"). This is ideal for comparing absolute values across panels. However, sometimes the data ranges vary so much between panels that this default makes it hard to see patterns within individual panels. The scales argument gives you control over this behavior 26:

* scales \= "free": Both x and y axes scales are independent for each panel.  
* scales \= "free\_x": X-axis scales are independent; y-axis is fixed.  
* scales \= "free\_y": Y-axis scales are independent; x-axis is fixed.

Choosing the right scale setting is a crucial decision based on whether the primary goal is to compare across panels (fixed scales) or to see the detail within each panel (free scales).

**Table 4.2: Comparison of facet\_wrap() and facet\_grid()**

| Feature | facet\_wrap() | facet\_grid() |
| :---- | :---- | :---- |
| **Primary Use Case** | Faceting by one or more variables, wrapped into a 2D layout. | Faceting by one or two variables in a rigid grid structure. |
| **Syntax** | \~ var1 \+ var2 | var\_rows \~ var\_cols |
| **Layout Control** | Flexible, controlled by nrow and ncol. | Rigid, determined by the number of levels in the faceting variables. |
| **Handling of Empty Combinations** | Does not show panels for combinations of levels not present in the data. | Shows all possible panels, including empty ones if combinations are missing. |
| **Best For** | A single categorical variable with many levels. | Two categorical variables where you want to see all combinations in a matrix. |

### **4.4.3 Visualizing Density: 1D and 2D Plots**

While histograms are excellent for understanding distributions, smoothed density plots can provide a clearer view of the underlying shape. This concept extends from one dimension to two, where heatmaps can reveal density in crowded scatter plots.

#### **1D Density with geom\_density**

A 1D density plot, created with geom\_density(), is a smoothed version of a histogram. It estimates the probability density function of a continuous variable, making it easier to see the distribution's shape without being distracted by the choice of binwidth.30 It is often useful to overlay a semi-transparent density plot on a histogram to get the benefits of both representations.31

R

ggplot(penguins, aes(x \= body\_mass\_g)) \+  
  \# Plot histogram with y-axis as density instead of count  
  geom\_histogram(aes(y \= after\_stat(density)), fill \= "lightblue", color \= "white", binwidth \= 250) \+  
  \# Overlay a density line  
  geom\_density(color \= "darkblue", linewidth \= 1) \+  
  theme\_minimal()

#### **2D Density (Heatmaps) with geom\_tile**

When a scatter plot suffers from overplotting (too many points stacked on top of each other), it can be difficult to discern the true density of the data. A heatmap is an excellent solution. The primary geom for creating heatmaps in ggplot2 is geom\_tile().17

A critical prerequisite for using geom\_tile() is that the data must be in a "long" or "tidy" format. This means you need a data frame with at least three columns: one for the x-axis position, one for the y-axis position, and one for the value that will be mapped to the fill color.33 Data, such as a correlation matrix, is often in a "wide" format and must be reshaped first, typically using the

pivot\_longer() function from the tidyr package.

Let's create a correlation matrix for the numeric variables in mtcars and visualize it as a heatmap.

R

\# 1\. Select only numeric columns and compute the correlation matrix  
cor\_matrix \<- mtcars %\>%  
  select(where(is.numeric)) %\>%  
  cor()

\# 2\. Reshape the matrix from wide to long format  
cor\_df \<- as.data.frame(cor\_matrix) %\>%  
  rownames\_to\_column(var \= "Var1") %\>%  
  pivot\_longer(  
    cols \= \-Var1,  
    names\_to \= "Var2",  
    values\_to \= "correlation"  
  )

\# 3\. Create the heatmap with geom\_tile()  
ggplot(cor\_df, aes(x \= Var1, y \= Var2, fill \= correlation)) \+  
  geom\_tile(color \= "white") \+ \# Add white lines between tiles  
  scale\_fill\_gradient2( \# Use a diverging color palette  
    low \= "blue", high \= "red", mid \= "white",  
    midpoint \= 0, limit \= c(-1, 1),  
    name \= "Correlation"  
  ) \+  
  theme\_minimal() \+  
  theme(axis.text.x \= element\_text(angle \= 45, vjust \= 1, hjust \= 1)) \+ \# Rotate x-axis labels  
  coord\_fixed() \# Ensure tiles are square

This process—calculate, reshape, plot—is a standard workflow for visualizing matrix data with ggplot2. Other geoms like geom\_bin2d() and geom\_hex() provide alternative ways to visualize 2D density by binning points into rectangles or hexagons, respectively.34

## **4.5 From Screen to Paper: Exporting Publication-Quality Graphics**

The final step in any visualization workflow is to save the plot for use in a publication, presentation, or report. The technical choices made at this stage directly impact the professional quality of the output. A beautiful plot can be ruined by poor export settings. ggplot2 provides the ggsave() function as a simple and reproducible way to ensure the visual quality created in R is preserved in the final document.35

### **The ggsave() Function**

ggsave() is the canonical function for saving ggplot objects. By default, it saves the last plot that was displayed in your R session. Its most powerful feature is that it can infer the desired file format from the extension you provide in the filename (e.g., .pdf, .png, .svg).36

The function's key arguments give you precise control over the final output.36

* filename: The name and path for the output file. The extension determines the file type.  
* plot: The specific plot object to save (e.g., plot \= my\_plot). Defaults to the last plot.  
* width, height, units: These control the physical dimensions of the saved image (e.g., units \= "in" or "cm"). Specifying these is crucial for consistency in documents and presentations.35  
* dpi: "Dots per inch," which controls the resolution for raster formats like PNG and JPEG. A common standard for print is 300 dpi, while 600 dpi provides higher resolution. For web, 72 dpi is often sufficient.36

R

\# First, create and polish a plot  
final\_plot \<- ggplot(penguins, aes(x \= flipper\_length\_mm, y \= body\_mass\_g, color \= species)) \+  
  geom\_point(alpha \= 0.8) \+  
  scale\_color\_brewer(palette \= "Dark2") \+  
  labs(  
    title \= "Body Mass vs. Flipper Length in Palmer Penguins",  
    x \= "Flipper Length (mm)",  
    y \= "Body Mass (g)",  
    color \= "Species"  
  ) \+  
  theme\_bw()

\# Now, save the plot using ggsave()  
ggsave(  
  filename \= "penguin\_plot.png",  
  plot \= final\_plot,  
  width \= 8,  
  height \= 6,  
  units \= "in",  
  dpi \= 300  
)

### **Best Practices for Publication**

#### **Vector vs. Raster Formats**

Understanding the difference between vector and raster graphics is critical for professional output.

* **Vector Graphics** (.pdf, .svg): These formats store images as a set of mathematical instructions for drawing lines and shapes. Their key advantage is infinite scalability; they can be resized to any dimension without losing quality or becoming pixelated. For most academic publications (which often use LaTeX or require PDF submissions), vector formats are strongly preferred.35  
* **Raster Graphics** (.png, .jpg, .tiff): These formats store images as a grid of pixels. They are ideal for complex images like photographs but will lose quality if scaled up beyond their original resolution. Use high-resolution PNGs (dpi \= 300 or higher) for plots with a very high density of points (where vector files can become very large and slow to render) or for web use.39

#### **Reproducibility**

Using ggsave() in your R script is a cornerstone of reproducible research. While it is possible to export a plot manually from the RStudio "Plots" pane, this action is not recorded in your code. Saving programmatically with ggsave() ensures that anyone (including your future self) can regenerate the exact same figure with the exact same dimensions and resolution simply by running the script.35

**Table 4.3: Key Arguments for ggsave()**

| Argument | Description | Example |
| :---- | :---- | :---- |
| filename | The name of the output file. The extension determines the file type. | "my\_plot.pdf", "figure1.png" |
| plot | The plot object to save. Defaults to the last plot displayed. | plot \= my\_scatter\_plot |
| width | The width of the saved plot. | width \= 7 |
| height | The height of the saved plot. | height \= 5 |
| units | The units for width and height. | units \= "in" (default), "cm", "mm" |
| dpi | The resolution in dots per inch (for raster formats like PNG). | dpi \= 300 (print), dpi \= 600 (high-res) |
| bg | The background color. Defaults to the plot's theme background. | bg \= "white" |

#### **Works cited**

1. Create Elegant Data Visualisations Using the Grammar of Graphics • ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/](https://ggplot2.tidyverse.org/)  
2. A ggplot2 Tutorial for Beautiful Plotting in R \- Cédric Scherer, accessed on July 30, 2025, [https://www.cedricscherer.com/2019/08/05/a-ggplot2-tutorial-for-beautiful-plotting-in-r/](https://www.cedricscherer.com/2019/08/05/a-ggplot2-tutorial-for-beautiful-plotting-in-r/)  
3. Introduction to the Grammar of Graphics, ggplot2, accessed on July 30, 2025, [https://seandavi.github.io/hour\_of\_code/ggplot2.html](https://seandavi.github.io/hour_of_code/ggplot2.html)  
4. The Grammar – ggplot2: Elegant Graphics for Data Analysis (3e), accessed on July 30, 2025, [https://ggplot2-book.org/mastery.html](https://ggplot2-book.org/mastery.html)  
5. Introduction to ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/articles/ggplot2.html](https://ggplot2.tidyverse.org/articles/ggplot2.html)  
6. 1 Data visualization – R for Data Science (2e), accessed on July 30, 2025, [https://r4ds.hadley.nz/data-visualize.html](https://r4ds.hadley.nz/data-visualize.html)  
7. ggplot2 \- Essentials \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/ggplot2-essentials](https://www.sthda.com/english/wiki/ggplot2-essentials)  
8. The Complete ggplot2 Tutorial \- Part1 | Introduction To ggplot2 (Full ..., accessed on July 30, 2025, [http://r-statistics.co/Complete-Ggplot2-Tutorial-Part1-With-R-Code.html](http://r-statistics.co/Complete-Ggplot2-Tutorial-Part1-With-R-Code.html)  
9. Grammar of Graphics | Introduction to R, accessed on July 30, 2025, [https://ramnathv.github.io/pycon2014-r/visualize/ggplot2.html](https://ramnathv.github.io/pycon2014-r/visualize/ggplot2.html)  
10. The grammar of graphics | Computing for Information Science, accessed on July 30, 2025, [https://info5940.infosci.cornell.edu/notes/dataviz/grammar-of-graphics/](https://info5940.infosci.cornell.edu/notes/dataviz/grammar-of-graphics/)  
11. A Grammar of Graphics \- Stat 20, accessed on July 30, 2025, [https://stat20.berkeley.edu/fall-2024/2-summarizing-data/03-a-grammar-of-graphics/tutorial.html](https://stat20.berkeley.edu/fall-2024/2-summarizing-data/03-a-grammar-of-graphics/tutorial.html)  
12. ggplot2 Quick Reference \- R-Statistics.co, accessed on July 30, 2025, [http://r-statistics.co/ggplot2-cheatsheet.html](http://r-statistics.co/ggplot2-cheatsheet.html)  
13. ggplot2 title : main, axis and legend titles \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/ggplot2-title-main-axis-and-legend-titles](https://www.sthda.com/english/wiki/ggplot2-title-main-axis-and-legend-titles)  
14. 8 Annotations – ggplot2: Elegant Graphics for Data Analysis (3e), accessed on July 30, 2025, [https://ggplot2-book.org/annotations.html](https://ggplot2-book.org/annotations.html)  
15. How can I change the title of a ggplot2 legend? \- Stack Overflow, accessed on July 30, 2025, [https://stackoverflow.com/questions/5911567/how-can-i-change-the-title-of-a-ggplot2-legend](https://stackoverflow.com/questions/5911567/how-can-i-change-the-title-of-a-ggplot2-legend)  
16. How to produce a heatmap with ggplot2? \- Stack Overflow, accessed on July 30, 2025, [https://stackoverflow.com/questions/8406394/how-to-produce-a-heatmap-with-ggplot2](https://stackoverflow.com/questions/8406394/how-to-produce-a-heatmap-with-ggplot2)  
17. ggplot2 heatmap – the R Graph Gallery, accessed on July 30, 2025, [https://r-graph-gallery.com/79-levelplot-with-ggplot2.html](https://r-graph-gallery.com/79-levelplot-with-ggplot2.html)  
18. Modify components of a theme \- ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/reference/theme.html](https://ggplot2.tidyverse.org/reference/theme.html)  
19. Complete themes — ggtheme \- ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/reference/ggtheme.html](https://ggplot2.tidyverse.org/reference/ggtheme.html)  
20. 17 Themes – ggplot2: Elegant Graphics for Data Analysis (3e), accessed on July 30, 2025, [https://ggplot2-book.org/themes.html](https://ggplot2-book.org/themes.html)  
21. How to annotate a plot in ggplot2 \- The R Graph Gallery, accessed on July 30, 2025, [https://r-graph-gallery.com/233-add-annotations-on-ggplot2-chart.html](https://r-graph-gallery.com/233-add-annotations-on-ggplot2-chart.html)  
22. Create an annotation layer \- ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/reference/annotate.html](https://ggplot2.tidyverse.org/reference/annotate.html)  
23. ggplot2 texts : Add text annotations to a graph in R software \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/ggplot2-texts-add-text-annotations-to-a-graph-in-r-software](https://www.sthda.com/english/wiki/ggplot2-texts-add-text-annotations-to-a-graph-in-r-software)  
24. How to nicely annotate a ggplot2 (manual) \- Stack Overflow, accessed on July 30, 2025, [https://stackoverflow.com/questions/2409357/how-to-nicely-annotate-a-ggplot2-manual](https://stackoverflow.com/questions/2409357/how-to-nicely-annotate-a-ggplot2-manual)  
25. ggplot2 facet : split a plot into a matrix of panels \- Easy Guides \- Wiki \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/ggplot2-facet-split-a-plot-into-a-matrix-of-panels](https://www.sthda.com/english/wiki/ggplot2-facet-split-a-plot-into-a-matrix-of-panels)  
26. FAQ: Faceting • ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/articles/faq-faceting.html](https://ggplot2.tidyverse.org/articles/faq-faceting.html)  
27. 16 Faceting – ggplot2 \- Elegant Graphics for Data Analysis, accessed on July 30, 2025, [https://ggplot2-book.org/facet.html](https://ggplot2-book.org/facet.html)  
28. Lay out panels in a grid — facet\_grid \- ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/reference/facet\_grid.html](https://ggplot2.tidyverse.org/reference/facet_grid.html)  
29. Facets in ggplot2 \[facet\_wrap and facet\_grid for multi panelling\] | R CHARTS, accessed on July 30, 2025, [https://r-charts.com/ggplot2/facets/](https://r-charts.com/ggplot2/facets/)  
30. Basic density chart with ggplot2 \- The R Graph Gallery, accessed on July 30, 2025, [https://r-graph-gallery.com/21-distribution-plot-using-ggplot2.html](https://r-graph-gallery.com/21-distribution-plot-using-ggplot2.html)  
31. How To Make Density Plots with ggplot2 in R? \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/how-to-make-density-plots-with-ggplot2-in-r/](https://www.geeksforgeeks.org/r-language/how-to-make-density-plots-with-ggplot2-in-r/)  
32. ggplot2 density plot : Quick start guide \- R software and data visualization \- STHDA, accessed on July 30, 2025, [https://www.sthda.com/english/wiki/ggplot2-density-plot-quick-start-guide-r-software-and-data-visualization](https://www.sthda.com/english/wiki/ggplot2-density-plot-quick-start-guide-r-software-and-data-visualization)  
33. Create Heatmap in R Using ggplot2 \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/create-heatmap-in-r-using-ggplot2/](https://www.geeksforgeeks.org/r-language/create-heatmap-in-r-using-ggplot2/)  
34. 2d density plot with ggplot2 \- The R Graph Gallery, accessed on July 30, 2025, [https://r-graph-gallery.com/2d-density-plot-with-ggplot2.html](https://r-graph-gallery.com/2d-density-plot-with-ggplot2.html)  
35. 2 Saving Plots | Using R Plots in Documents \- Social Science Computing Cooperative, accessed on July 30, 2025, [https://sscc.wisc.edu/sscc/pubs/using-r-plots/saving-plots.html](https://sscc.wisc.edu/sscc/pubs/using-r-plots/saving-plots.html)  
36. Save a ggplot (or other grid object) with sensible defaults — ggsave \- ggplot2, accessed on July 30, 2025, [https://ggplot2.tidyverse.org/reference/ggsave.html](https://ggplot2.tidyverse.org/reference/ggsave.html)  
37. How to Save a GGPlot: The Best Reference \- Datanovia.com, accessed on July 30, 2025, [https://www.datanovia.com/en/blog/how-to-save-a-ggplot/](https://www.datanovia.com/en/blog/how-to-save-a-ggplot/)  
38. How to Use ggsave to Quickly Save ggplot2 Plots \- Statology, accessed on July 30, 2025, [https://www.statology.org/ggsave-r/](https://www.statology.org/ggsave-r/)  
39. ggsave in r \- GeeksforGeeks, accessed on July 30, 2025, [https://www.geeksforgeeks.org/r-language/ggsave-in-r/](https://www.geeksforgeeks.org/r-language/ggsave-in-r/)