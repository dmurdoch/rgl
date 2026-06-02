# shapelist3d works with col (issue #462)

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["material", "objects"]
        }
      },
      "value": [
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["color", "alpha", "lit", "ambient", "specular", "emission", "shininess", "smooth", "front", "back", "size", "lwd", "fog", "point_antialias", "line_antialias", "textures", "textype", "texmode", "texmipmap", "texminfilter", "texmagfilter", "texenvmap", "depth_mask", "depth_test", "isTransparent", "polygon_offset", "margin", "floating", "tag", "blend", "vertex_shader", "fragment_shader", "user_attributes", "user_uniforms"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["#000000"]
            },
            {
              "type": "double",
              "attributes": {},
              "value": [1]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [true]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["#000000"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["#FFFFFF"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["#000000"]
            },
            {
              "type": "double",
              "attributes": {},
              "value": [50]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [true]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["filled"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["filled"]
            },
            {
              "type": "double",
              "attributes": {},
              "value": [3]
            },
            {
              "type": "double",
              "attributes": {},
              "value": [1]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [true]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [false]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [false]
            },
            {
              "type": "list",
              "attributes": {},
              "value": []
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["rgb"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["modulate"]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [false]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["linear"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["linear"]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [false]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [true]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["less"]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [false]
            },
            {
              "type": "double",
              "attributes": {},
              "value": [0, 0]
            },
            {
              "type": "character",
              "attributes": {},
              "value": [""]
            },
            {
              "type": "logical",
              "attributes": {},
              "value": [false]
            },
            {
              "type": "character",
              "attributes": {},
              "value": [""]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["src_alpha", "one_minus_src_alpha"]
            },
            {
              "type": "character",
              "attributes": {
                "class": {
                  "type": "character",
                  "attributes": {},
                  "value": ["rglShader"]
                },
                "type": {
                  "type": "character",
                  "attributes": {},
                  "value": ["vertex"]
                }
              },
              "value": [""]
            },
            {
              "type": "character",
              "attributes": {
                "class": {
                  "type": "character",
                  "attributes": {},
                  "value": ["rglShader"]
                },
                "type": {
                  "type": "character",
                  "attributes": {},
                  "value": ["fragment"]
                }
              },
              "value": [""]
            },
            {
              "type": "list",
              "attributes": {},
              "value": []
            },
            {
              "type": "list",
              "attributes": {},
              "value": []
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["8", "9", "5", "7"]
            }
          },
          "value": [
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["id", "type", "material", "vertices", "colors", "centers", "indices", "normals", "ignoreExtent"]
                },
                "class": {
                  "type": "character",
                  "attributes": {},
                  "value": ["rglquads", "rglobject"]
                }
              },
              "value": [
                {
                  "type": "double",
                  "attributes": {},
                  "value": [8]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["quads"]
                },
                {
                  "type": "list",
                  "attributes": {
                    "names": {
                      "type": "character",
                      "attributes": {},
                      "value": ["color"]
                    }
                  },
                  "value": [
                    {
                      "type": "character",
                      "attributes": {},
                      "value": ["#FF0000"]
                    }
                  ]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [24, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [0, 0, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [1, 4]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["r", "g", "b", "a"]
                        }
                      ]
                    }
                  },
                  "value": [1, 0, 0, 1]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [6, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [1, 1, 2, 0, 1, 1, 1, 2, 1, 1, 0, 1, 0, 1, 1, 1, 1, 2]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [24, 1]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["vertex"]
                        }
                      ]
                    }
                  },
                  "value": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [24, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1]
                },
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [false]
                }
              ]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["id", "type", "material", "vertices", "colors", "centers", "indices", "normals", "ignoreExtent"]
                },
                "class": {
                  "type": "character",
                  "attributes": {},
                  "value": ["rglquads", "rglobject"]
                }
              },
              "value": [
                {
                  "type": "double",
                  "attributes": {},
                  "value": [9]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["quads"]
                },
                {
                  "type": "list",
                  "attributes": {
                    "names": {
                      "type": "character",
                      "attributes": {},
                      "value": ["color"]
                    }
                  },
                  "value": [
                    {
                      "type": "character",
                      "attributes": {},
                      "value": ["#0000FF"]
                    }
                  ]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [24, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [1, 1, 3, 3, 1, 1, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 3, 3, 1, 1, 3, 3, 1, 0, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [1, 4]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["r", "g", "b", "a"]
                        }
                      ]
                    }
                  },
                  "value": [0, 0, 1, 1]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [6, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [2, 2, 3, 1, 2, 2, 1, 2, 1, 1, 0, 1, 0, 1, 1, 1, 1, 2]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [24, 1]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["vertex"]
                        }
                      ]
                    }
                  },
                  "value": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [24, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1]
                },
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [false]
                }
              ]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["id", "type", "vertices", "colors", "viewpoint", "finite"]
                },
                "class": {
                  "type": "character",
                  "attributes": {},
                  "value": ["rgllight", "rglobject"]
                }
              },
              "value": [
                {
                  "type": "double",
                  "attributes": {},
                  "value": [5]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["light"]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [1, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [0, 0, 1]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [3, 4]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["r", "g", "b", "a"]
                        }
                      ]
                    }
                  },
                  "value": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                },
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [true]
                },
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [false]
                }
              ]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["id", "type", "material", "colors", "centers", "sphere", "fogtype", "fogscale"]
                },
                "class": {
                  "type": "character",
                  "attributes": {},
                  "value": ["rglbackground", "rglobject"]
                }
              },
              "value": [
                {
                  "type": "double",
                  "attributes": {},
                  "value": [7]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["background"]
                },
                {
                  "type": "list",
                  "attributes": {
                    "names": {
                      "type": "character",
                      "attributes": {},
                      "value": ["color", "lit", "back"]
                    }
                  },
                  "value": [
                    {
                      "type": "character",
                      "attributes": {},
                      "value": ["#FFFFFF"]
                    },
                    {
                      "type": "logical",
                      "attributes": {},
                      "value": [false]
                    },
                    {
                      "type": "character",
                      "attributes": {},
                      "value": ["lines"]
                    }
                  ]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [1, 4]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["r", "g", "b", "a"]
                        }
                      ]
                    }
                  },
                  "value": [1, 1, 1, 1]
                },
                {
                  "type": "double",
                  "attributes": {
                    "dim": {
                      "type": "integer",
                      "attributes": {},
                      "value": [1, 3]
                    },
                    "dimnames": {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "NULL"
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["x", "y", "z"]
                        }
                      ]
                    }
                  },
                  "value": [0, 0, 0]
                },
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [false]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["none"]
                },
                {
                  "type": "double",
                  "attributes": {},
                  "value": [1]
                }
              ]
            }
          ]
        }
      ]
    }

