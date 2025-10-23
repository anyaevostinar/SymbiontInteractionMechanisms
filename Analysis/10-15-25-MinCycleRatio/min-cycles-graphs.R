
# =================== load libraries ===================
library(tidyverse)
library(dplyr)
library(ggplot2)
library(viridis)
library(ggsci)
library(paletteer)


# =================== load & preprocess data ===================
ratios <- c("100-10","80-10","70-10","100-15", "150-25","60-10","50-10", 
            "150-35", "100-25", "80-25", "60-25", "150-75", "100-50", 
            "80-40", "60-30", "50-25", "150-100", "60-40", "80-60", 
            "100-100", "50-50")
sums <- c("150-100", "150-75", "100-100", "150-35", "150-25", "100-50",
          "80-60", "100-25", "80-40","100-15","100-10", "80-25", "50-50", 
          "60-40","80-10", "60-30", "60-25","70-10", "50-25", 
          "60-10", "50-10")
threshold <- 500

prelim_1 <- read.table("data/50-25.dat", h=T) |>
  mutate(treatment = "50-25")
prelim_2 <- read.table("data/50-50.dat", h=T) |>
  mutate(treatment = "50-50")
prelim_3 <- read.table("data/100-25.dat", h=T) |>
  mutate(treatment = "100-25")
prelim_4 <- read.table("data/100-50.dat", h=T) |>
  mutate(treatment = "100-50")
prelim_5 <- read.table("data/100-100.dat", h=T) |>
  mutate(treatment = "100-100")
prelim_6 <- read.table("data/150s.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))
prelim_7 <- read.table("data/below-80s.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))
prelim_8 <- read.table("data/ratio.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))

full_data <- bind_rows(prelim_1, prelim_2, prelim_3, prelim_4,
                       prelim_5, prelim_6, prelim_7, prelim_8) |>
  filter(partner != "Symbiont") |>   # remove Symbiont rows
  select(-uid, -partner) |> # remove uid and partner columns
  mutate( # order tasks by difficulty
    task = factor(task, levels = c("NOT", "NAND", "ORN", "AND", "OR", 
                                   "ANDN", "NOR", "XOR", "EQU")),
    rep = as.factor(rep)
  )

sym_data <- bind_rows(prelim_1, prelim_2, prelim_3, prelim_4,
                       prelim_5, prelim_6, prelim_7, prelim_8) |>
  filter(partner != "Host") |>   # remove Host rows
  select(-uid) |> # remove uid column
  mutate( # order tasks by difficulty
    task = factor(task, levels = c("NOT", "NAND", "ORN", "AND", "OR", 
                                   "ANDN", "NOR", "XOR", "EQU")))

final_update_syms <- sym_data |>
  filter(update == 500000)

final_update_only <- full_data |>
  filter(update == 500000)
  
# =================== plot 1 - hosts ===================

# create flag for whether the rep did the task
plot2_data <- final_update_only |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = ratios)) |>
  group_by(task, treatment) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

# bar graph
ggplot(plot2_data, aes(x = treatment, y = num_reps, fill = treatment)) +
  geom_col() +
  facet_wrap(~ task) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Number of Reps",
    title = "Host reps that completed each task by treatment",
    subtitle ="(final update only, treatments ordered by ratio)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

# =================== plot 2: avg host tasks (all updates) ===================

plot3_data <- full_data |>
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
    title = "Average number of tasks done by treatment (Hosts only)",
    subtitle = "(all updates included)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

# =================== plot 3 - sym data ===================

plot2_data <- final_update_syms |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = ratios)) |>
  group_by(task, treatment) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

# bar graph
ggplot(plot2_data, aes(x = treatment, y = num_reps, fill = treatment)) +
  geom_col() +
  facet_wrap(~ task) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Number of Reps",
    title = "Sym reps that completed each task by treatment",
    subtitle ="(final update only, treatments ordered by ratio)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

# =================== plot 4: avg sym tasks (all updates) ===================

plot3_data <- sym_data |>
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
    title = "Average number of tasks done by treatment (Syms only)",
    subtitle = "(all updates included)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )


