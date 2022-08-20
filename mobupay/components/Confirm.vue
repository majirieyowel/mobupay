<template>
  <v-dialog v-model="show" persistent max-width="290">
    <v-card>
      <v-card-title class="text-h5">
        {{ title }}
      </v-card-title>
      <v-card-text>{{ instruction }}</v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <div>
          <v-btn color="grey d darken-1" text @click="$emit('no')"> No </v-btn>
          <v-btn color="green darken-1" text @click="$emit('yes', param)">
            Yes
          </v-btn>
        </div>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: "confirm",
  emits: ["yes", "no"],
  data: () => ({}),
  props: {
    show: Boolean,
    title: String,
    instruction: String,
    param: String,
  },
};
</script>

<style scoped>
</style>

