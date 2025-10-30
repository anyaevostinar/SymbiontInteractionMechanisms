
# =================== load libraries ===================
library(tidyverse)
library(dplyr)
library(ggplot2)
library(paletteer)
library(viridis)


# =================== load & preprocess data ===================

ratios <- c("100-10","80-10","70-10","100-15", "150-25","60-10","50-10", 
            "150-35", "100-25", "80-25", "60-25", "150-75", "100-50", 
            "80-40", "60-30", "50-25", "150-100", "60-40", "80-60", 
            "100-100", "50-50")
threshold <- 500

raw_data <- read.table("data/HeathMinCycleTest2.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))

steal_data <- read.table("data/HeathMinCycleTestSymInst2.dat", h=T) |>
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

# =================== plot 2: avg tasks (all updates) ===================

plot3_data <- clean_data |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = ratios)
  ) |>
  group_by(treatment, rep, task) |>
  summarise(did_task = any(did_task), .groups = "drop") |> 
  group_by(treatment, rep) |>
  summarise(num_tasks_done = sum(did_task), .groups = "drop") |> 
  group_by(treatment) |>
  summarise(avg_tasks_done = mean(num_tasks_done), .groups = "drop") 

ggplot(plot3_data, aes(x = reorder(treatment, -avg_tasks_done),
                       y = avg_tasks_done,
                       fill = reorder(treatment, -avg_tasks_done))) +
  geom_col() +
  scale_fill_viridis_d(option = "turbo", end = 0.9) +
  labs(
    x = "Treatment (ordered by average tasks done)",
    y = "Average # of Different Tasks Done",
    title = "Average number of different tasks done by treatment",
    subtitle = "(all updates included)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

# =================== plot 3: steal instructions over time ===================

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
    title = "Average symbiont steal instruction count over time")



