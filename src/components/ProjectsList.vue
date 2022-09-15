<template>
  <v-container>
    <v-row class="text-center justify-space-around">
      <v-col
        md="12"
        class="align-self-center"
      >
        <v-card
          width="800"
          class="ma-auto justify-center"
        >
          <v-card-title>Quick Filters</v-card-title>
          <v-card-subtitle>Filter grants based on statuses and/or tags</v-card-subtitle>
          <v-card-text>
            <v-card
              class="mx-auto my-4"
              variant="tonal"
              density="compact"
            >
              <template v-slot:title>
                Filter on grant status
              </template>
              <v-card-text>
                <v-progress-circular
                  v-if="statuses.length === 0"
                  indeterminate
                  color="primary"
                ></v-progress-circular>
                <v-chip-group
                  v-if="statuses.length !== 0"
                  v-model="selectedStatuses"
                  class="justify-center"
                  column
                  multiple
                >
                  <v-chip
                    filter
                    v-for="status in statuses"
                    @click="page=1; fetchProjects()"
                  >
                    {{ status.status }} ({{status.count}})
                  </v-chip>
                </v-chip-group>
              </v-card-text>
            </v-card>
            <v-card
              class="mx-auto my-4"
              variant="tonal"
              density="compact"
            >
              <template v-slot:title>
                Filter on tags
              </template>
              <v-card-text>
                <v-progress-circular
                  v-if="tags.length === 0"
                  indeterminate
                  color="primary"
                ></v-progress-circular>
                <v-chip-group
                  v-if="tags.length !== 0"
                  v-model="selectedTags"
                  column
                  multiple
                  class="justify-center"
                >
                  <v-chip
                    filter
                    v-for="tag in tags"
                    @click="filterTags(tag.tag)"
                  >
                    {{ tag.tag }} ({{tag.count}})
                  </v-chip>
                </v-chip-group>
              </v-card-text>
            </v-card>
            <v-card
              class="mx-auto my-4"
              variant="tonal"
              density="compact"
            >
              <template v-slot:title>
                Filter on text in title and/or description
              </template>
              <v-card-text>
                <v-form ref="form" lazy-validation>
                  <v-text-field
                    label="Search"
                    v-model="search"
                    :rules="[rules.noSpecialChars]"
                  />
                </v-form>
              </v-card-text>
            </v-card>
            <h2 class="my-3">Icon Legend</h2>
            <v-icon
              size="large"
              left
              icon="mdi-information"
              color="info"
            ></v-icon>
            No vote on the milestone yet.
            <v-icon
              size="large"
              left
              icon="mdi-check-circle"
              color="lime"
            ></v-icon>
            Informal vote done.
            <v-icon
              size="large"
              left
              icon="mdi-check-circle"
              color="success"
            ></v-icon>
            Formal vote done.
          </v-card-text>
        </v-card>
      </v-col>
      <v-col
        md="3"
        v-for="project in projects"
      >
        <Project :project="project" />
      </v-col>
      <v-col cols="12">
        <v-row class="justify-center">
          <v-col cols="4">
            <v-pagination
              v-model="page"
              :length="totalPages"
            ></v-pagination>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import Project from './ProjectComponent.vue';
  import debounce from 'lodash.debounce';

  export default {
    name: 'ProjectsList',
    components: { Project },
    data: () => ({
      projects: [],
      tags: [],
      statuses: [],
      selectedTags: [],
      selectedStatuses: [],
      totalProjects: 0,
      page: 1,
      search: '',
      debounceFetchProjects: null,
      rules: {
        noSpecialChars: value => {
          const pattern = /^[\w\s]*$/
          return pattern.test(value) || 'No special chars allowed'
        },
      },
    }),
    created() {
      this.debounceFetchProjects = debounce(this.fetchProjects, 250);
    },
    computed: {
      totalPages() {
        return Math.ceil(this.totalProjects / 12);
      },
    },
    async mounted() {
      const pProjects = this.fetchProjects();
      const pTags = this.fetchTags();
      const pStatuses = this.fetchStatuses();
      await Promise.all([pProjects, pTags, pStatuses]);
    },
    watch: {
      page() {
        this.debounceFetchProjects();
      },
      search() {
        this.debounceFetchProjects();
      },
    },
    methods: {
      filterTags(tag) {
        const selectedTags = [];
        this.selectedTags.forEach((i) => selectedTags.push(this.tags[i].tag));
        if (tag === 'None') {
          this.selectedTags = [this.tags.findIndex((i) => i.tag === 'None')];
        } else if (selectedTags.includes('None')) {
          const noneIndex = this.selectedTags.findIndex((i) => i === this.tags.findIndex((i) => i.tag === 'None'));
          this.selectedTags.splice(noneIndex, 1);
        }
        this.debounceFetchProjects();
      },
      async fetchProjects() {
        const selectedTags = [];
        this.selectedTags.forEach((i) => selectedTags.push(this.tags[i].tag));
        let filterTags = '';
        if (selectedTags.length > 0) {
          if (selectedTags.includes('None')) {
            filterTags = `&tags=is.null`;
          } else {
            filterTags = `&tags=cs.{${selectedTags.join(',')}}`;
          }
        }
        console.log(filterTags);
        const selectedStatuses = [];
        this.selectedStatuses.forEach((i) => selectedStatuses.push(this.statuses[i].status));
        let filterStatuses = '';
        if (selectedStatuses.length > 0) {
          filterStatuses = `&status=in.(${selectedStatuses.join(',')})`;
        }
        let sqlSearch = '';
        if (this.search !== '') {
          this.$refs.form.validate();
          const trimSearch = encodeURI(this.search.trim());
          sqlSearch = `&or=(title.ilike.*${trimSearch}*,short_description.ilike.*${trimSearch}*)`;
        }
        const offset = (this.page - 1) * 12;
        const response = await fetch(`${import.meta.env.VITE_POSTGREST}/projects?limit=12${filterTags}${filterStatuses}${sqlSearch}&offset=${offset}`, {
          method: 'GET',
          headers: new Headers({
            'Range-Unit': 'items',
            Prefer: 'count=exact',
          }),
        });
        this.totalProjects = this.parseContentRange(response.headers.get('content-range')).size;
        this.projects = await response.json();
      },
      async fetchTags() {
        this.tags = await (await fetch(`${import.meta.env.VITE_POSTGREST}/tags_stats`)).json();
      },
      async fetchStatuses() {
        this.statuses = await (await fetch(`${import.meta.env.VITE_POSTGREST}/statuses_stats`)).json();
      },
      parseContentRange(contentRange) {
        if (contentRange === '*/0') {
          return { start: 0, end: 0, size: 0 };
        }

        const contentRangeParts = contentRange.split(/[-/]/);

        return {
          start: Number(contentRangeParts[0]),
          end: Number(contentRangeParts[1]),
          size: Number(contentRangeParts[2]),
        };
      },
    },
  };
</script>
