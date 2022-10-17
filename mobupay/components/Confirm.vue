<template>
  <v-dialog
    v-model="show"
    :max-width="maxWidth"
    overlay-opacity="0.7"
    @click:outside="$emit('no')"
  >
    <v-card>
      <v-card-title class="text-h5">
        {{ title }}
      </v-card-title>
      <v-card-text>
        <slot></slot>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <div class="dialogue--action--buttons">
          <v-btn color="grey d darken-1" text @click="$emit('no')"> No </v-btn>
          <v-btn color="green darken-1" text @click="$emit('yes', item_ref)">
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
  data: () => ({
    maxWidth: 330,
  }),
  props: {
    show: Boolean,
    title: String,
    item_ref: String,
  },
  beforeMount() {
    if (screen.width < 600) {
      this.maxWidth = "330px";
    } else {
      this.maxWidth = "400px";
    }
  },
  mounted() {},
};
</script>

<style lang="scss" scoped>
.dialogue--action--buttons {
  display: flex;
  justify-content: space-between;
  width: 100%;
  border-top: 1px dashed #eee;
  padding-top: 9px;
}
</style>

