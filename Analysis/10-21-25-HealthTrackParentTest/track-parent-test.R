
# =================== load libraries ===================
library(tidyverse)
library(dplyr)
library(ggplot2)
library(paletteer)
library(viridis)


# =================== load & preprocess data ===================

ratios <- c("150-25","100-25", "80-25")

threshold <- 500

raw_data <- read.table("data/HealthTrackParent.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))

steal_data <- read.table("data/HealthTrackParentTestSymInst.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))

clean_data <- raw_data |>
  select(-uid) |> # remove uid column
  mutate( # order tasks by difficulty
    task = factor(task, levels = c("NOT", "NAND", "ORN", "AND", "OR", 
                                   "ANDN", "NOR", "XOR", "EQU")),
    partner = as.factor(partner))


final_update_only <- clean_data |>
  filter(update == 100000)

# =================== plot 1 ===================

# create flag for whether the rep did the task
plot2_data <- final_update_only |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = ratios)
  ) |>
  group_by(task, treatment, partner) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

# bar graph
ggplot(plot2_data, aes(x = treatment, y = num_reps, fill = partner)) +
  geom_col(position = "dodge") +  # side-by-side bars for Host vs Symbiont
  facet_wrap(~ task) +
  scale_fill_manual(values = c("Host" = "blue", "Symbiont" = "red")) +
  labs(
    x = "Treatment",
    y = "Number of Reps",
    fill = "Type",
    title = "Number of reps that completed each task by treatment and partner",
    subtitle = "(final update only)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )


# =================== plot 2: steal instructions over time ===================

ggplot(data = steal_data, aes(x = update, y = sym_steal_ran, group = treatment, colour = treatment)) + 
  ylab("Average Steal Count (×1000)") + 
  xlab("Update (×1000)") +
  stat_summary(
    aes(color = treatment, fill = treatment),
    fun.data = "mean_cl_boot",
    geom = "smooth",
    se = TRUE) +
  theme(
    panel.background = element_rect(fill = 'white', colour = 'black'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "bottom") +
  guides(fill = FALSE) +
  scale_colour_manual(name = "Treatment", values = viridis(3)) +
  scale_fill_manual(values = viridis(3)) +
  scale_x_continuous(
    breaks = seq(0, 100000, by = 5000), 
    labels = function(x) x / 1000) +
  scale_y_continuous(
    labels = function(y) y / 1000) +
  labs(
    title = "Average symbiont steal instruction count over time",
    subtitle = "(Mean ± 95% CI, averaged over all reps per treatment)")



