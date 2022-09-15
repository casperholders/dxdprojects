<template>
  <div>
    <v-dialog
      v-model="dialog"
      class="ma-5"
    >
      <template v-slot:activator="{props}">
        <v-card>
          <v-card-title>{{ sanitize(project.id) }} - {{ sanitize(project.title) }}</v-card-title>
          <v-card-subtitle>{{ sanitize(project.short_description) }}</v-card-subtitle>
          <v-container class="d-flex overflow-x-auto justify-center">
            <v-chip
              v-for="tag in project.tags"
              class="mr-2 mt-2"
            >{{ sanitize(tag) }}
            </v-chip>
            <v-chip
              v-if="!project.tags"
              class="mr-2 mt-2"
            >None
            </v-chip>
          </v-container>
          <v-card-text>
            <v-card
              class="mx-auto my-4"
              variant="tonal"
              density="compact"
            >
              <template v-slot:title>
                Grant status : {{ sanitize(project.status) }}
              </template>
            </v-card>
            <v-card
              class="mx-auto my-4"
              variant="tonal"
              density="compact"
            >
              <template v-slot:title>
                Milestones statuses
                <div>
                  <v-icon
                    v-for="milestone in formatMilestones(project.milestones)"
                    size="large"
                    left
                    :icon="milestone.icon"
                    :color="milestone.color"
                  ></v-icon>
                </div>
              </template>
            </v-card>
          </v-card-text>
          <v-card-actions>
            <v-spacer />
            <v-btn
              variant="outlined"
              v-bind="props"
            >
              Learn more
            </v-btn>
            <v-spacer />
          </v-card-actions>
        </v-card>
      </template>
      <v-card>
        <v-card-title class="text-center text-wrap">
          {{ sanitize(project.title) }}
        </v-card-title>
        <v-card-text class="">
          <h2 class="my-3">Status</h2>
          <pre>{{ sanitize(project.status) }}</pre>
          <template v-if="project.linkedin">
            <h2 class="my-3">LinkedIn</h2>
            <pre>{{ sanitize(project.linkedin) }}</pre>
          </template>
          <template v-if="project.github">
            <h2 class="my-3">GitHub</h2>
            <pre>{{ sanitize(project.github) }}</pre>
          </template>
          <template v-if="project.resume">
            <h2 class="my-3">Resume</h2>
            <pre>{{ sanitize(project.resume) }}</pre>
          </template>
          <h2 class="my-3">Tags</h2>
          <v-chip
            v-for="tag in project.tags"
            class="mr-2 mt-2"
          >{{ sanitize(tag) }}
          </v-chip>
          <h2 class="my-3">Status</h2>
          <pre>{{ sanitize(project.status) }}</pre>
          <h2 class="my-3">Description</h2>
          <pre>{{ sanitize(project.short_description) }}</pre>
          <h2 class="my-3 text-wrap">What problem this grant would solve ?</h2>
          <pre>{{ project.explanation_solve !== '' ? sanitize(project.explanation_solve) : 'N/A' }}</pre>
          <h2 class="my-3 text-wrap">What benefits this grant would add to the ecosytem ?</h2>
          <pre>{{ project.explanation_benefit !== '' ? sanitize(project.explanation_benefit) : 'N/A' }}</pre>
          <h2 class="my-3 text-wrap">What's the goal of the grant ?</h2>
          <pre>{{ project.explanation_goal !== '' ? sanitize(project.explanation_goal) : 'N/A' }}</pre>
          <h2 class="my-3">Grant budget</h2>
          <pre>{{ formatBudget(project.total_grant) }}</pre>
          <h2 class="my-3">Icon Legend</h2>
          <div>
            <v-icon
              size="large"
              left
              class="mr-3"
              icon="mdi-information"
              color="info"
            ></v-icon>
            No vote on the milestone yet.
          </div>
          <div>
            <v-icon
              size="large"
              left
              class="mr-3"
              icon="mdi-check-circle"
              color="lime"
            ></v-icon>
            Informal vote done.
          </div>
          <div>
            <v-icon
              size="large"
              left
              class="mr-3"
              icon="mdi-check-circle"
              color="success"
            ></v-icon>
            Formal vote done.
          </div>
          <v-expansion-panels class="my-3">
            <v-expansion-panel
              v-for="milestone in project.milestones"
              :key="milestone.id"
            >
              <v-expansion-panel-title>
                <v-icon
                  size="large"
                  left
                  class="mr-3"
                  :icon="formatMilestone(milestone).icon"
                  :color="formatMilestone(milestone).color"
                ></v-icon>
                {{ sanitize(milestone.title) }}
              </v-expansion-panel-title>
              <v-expansion-panel-text>
                <template v-if="milestone.url">
                  <h2 class="my-3">Deliverable</h2>
                  <pre>{{ sanitize(milestone.url) }}</pre>
                </template>
                <h2 class="my-3">Details</h2>
                <pre>{{ sanitize(milestone.details) }}</pre>
                <h2 class="my-3">Acceptance criteria</h2>
                <pre>{{ sanitize(milestone.criteria) }}</pre>
                <h2 class="my-3">Provisional deadline</h2>
                <pre>{{ sanitize(milestone.deadline) }}</pre>
                <h2 class="my-3">Budget</h2>
                <pre>{{ formatBudget(milestone.grant) }}</pre>
              </v-expansion-panel-text>
            </v-expansion-panel>
          </v-expansion-panels>
        </v-card-text>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
  import DOMPurify from 'dompurify';

  export default {
    name: 'Project',
    props: ['project'],
    data: () => ({
      dialog: false,
    }),
    methods: {
      sanitize(s) {
        return DOMPurify.sanitize(s);
      },
      formatBudget(s) {
        return new Intl.NumberFormat(undefined, { style: 'currency', currency: 'EUR' }).format(this.sanitize(s));
      },
      formatMilestones(milestones) {
        const formatted = [];
        for (const milestone of milestones) {
          formatted.push(this.formatMilestone(milestone));
        }
        return formatted;
      },
      formatMilestone(milestone) {
        let icon = 'mdi-information';
        let color = 'info';
        if (milestone.informal) {
          icon = 'mdi-check-circle';
          color = 'lime';
        }
        if (milestone.formal) {
          color = 'success';
        }
        return {
          icon: icon,
          color: color,
        };
      },
    },
  };
</script>

<style scoped>
    .v-chip {
        overflow: initial;
    }

    pre {
        white-space: pre-wrap; /* css-3 */
        white-space: -moz-pre-wrap; /* Mozilla, since 1999 */
        white-space: -pre-wrap; /* Opera 4-6 */
        white-space: -o-pre-wrap; /* Opera 7 */
        word-wrap: break-word; /* Internet Explorer 5.5+ */
        word-break: break-word;
    }
</style>
