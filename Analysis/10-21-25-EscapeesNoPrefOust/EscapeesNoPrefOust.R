# =================== load libraries ===================
library(tidyverse)
library(dplyr)
library(ggplot2)
library(paletteer)

# =================== load & preprocess data ===================

threshold <- 500

raw_data <- read.table("data/munged_basic.dat", h=T) |>
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
    treatment = factor(treatment)
  ) |>
  group_by(task, treatment, partner) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

# bar graph
ggplot(plot2_data, aes(x = treatment, y = num_reps, fill = partner)) +
  geom_col(position = "dodge") +  # side-by-side bars for Host vs Symbiont
  facet_wrap(~ task) +
  scale_fill_manual(values = c("Host" = "blue", "Symbiont" = "red")) +
  labs(
    x = "PARASITE_NUM_OFFSPRING_ON_STRESS_INTERACTION",
    y = "Number of Reps",
    fill = "Type",
    title = "Number of reps that \"did\" each task by treatment and partner",
    subtitle = "(final update only, SYMBIONTS_ESCAPE 1, Host min cycles 100, Sym min cycles 10)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

