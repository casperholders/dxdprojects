<template>
  <v-app>
    <v-main>
      <Header />
      <ProjectsList class="mb-3"/>
    </v-main>
    <v-footer inset
              absolute>
      <div class="mx-auto">
        <p class="mb-0 text-center">
          <a
            class="text-decoration-none"
            href="/"
          >
            <strong>
              DEVxDAO Projects
            </strong>
          </a>
          by the creators of
          <a
            class="text-decoration-none"
            target="_blank"
            href="https://casperholders.io"
          >
            <strong>
              CasperHolders &#128150;
            </strong>
          </a><br/>
          <b>This is an unofficial website based on the informations from the DEVxDAO.</b>
        </p>
        <p class="mb-0 text-center text-caption">
          Hosted by OVH - 2 rue Kellermann - 59100 Roubaix - France - 1077 (+33 9
          72 10 10 07)
        </p>
      </div>
    </v-footer>
  </v-app>
</template>

<script>
  import Header from './components/Header.vue';
  import ProjectsList from './components/ProjectsList.vue';

  export default {
    name: 'App',

    components: {
      ProjectsList,
      Header,
    },

    data: () => ({
      //
    }),
  };
</script>

<style>
    body {
        font-family: "Roboto", Helvetica, Arial, sans-serif;
        background-color: #00126b;
    }
    /* Works on Firefox */
    * {
        scrollbar-width: thin;
    }

    /* Works on Chrome, Edge, and Safari */
    *::-webkit-scrollbar {
        width: 12px;
        height: 10px;
    }

    *::-webkit-scrollbar-track {
        background: #0077B6;
    }

    *::-webkit-scrollbar-thumb {
        background-color: #00B4D8;
        border-radius: 20px;
    }

    #app::before {
        content: " ";
        position: fixed;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-color: #00126b;
        background-image: url("/islands.svg");
        background-size: cover;
        will-change: transform;
    }

    .app__wrapper {
        position: relative;
        z-index: 1;
    }

</style>
