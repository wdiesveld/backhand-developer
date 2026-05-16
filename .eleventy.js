module.exports = function(eleventyConfig) {
  // Pass through copy for static assets
  eleventyConfig.addPassthroughCopy("app/css");
  eleventyConfig.addPassthroughCopy("app/js");
  eleventyConfig.addPassthroughCopy("app/images");
  eleventyConfig.addPassthroughCopy("app/data");

  // Add filter for current year
  eleventyConfig.addNunjucksFilter("currentYear", function() {
    return new Date().getFullYear();
  });

  // Configure template formats
  eleventyConfig.setTemplateFormats(["njk", "html", "json"]);

  // Return 11ty config object
  return {
    dir: {
      input: "app",
      output: "dist",
      includes: "_includes",
      layouts: "_includes"
    },
    templateFormats: ["njk", "html"],
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    dataTemplateEngine: "njk"
  };
};
