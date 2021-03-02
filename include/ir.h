#ifndef IR_H
#define IR_H

typedef struct n
{
    node_index_t type;
    void *data;
    void *entry;
    uint64_t n_children;
    struct n **children;
} node_t;

void node_init(
    node_t *n, node_index_t type, void *data, uint64_t n_children, ...);

/**
 * Allocate and initialize new node
 * @param type Type of the new node
 * @param data Pointer to auxiliary data
 * @param n_children Number of children
 * @param ... Pointers to children
 * @return Pointer to new node
 */
void node_init(node_t *nd, node_index_t type, void *data, uint64_t n_children, va_list children);

void node_print(node_t *root, int nesting);
void node_finalize(node_t *discard);
void destroy_subtree(node_t *discard);
#endif
